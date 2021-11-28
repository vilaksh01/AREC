import certificate_roots
import http
import net
import tls
import encoding.json
import i2c
import bme280
import gpio

// replace host address with ngrok http tunnel adress for DAML localhost server
DAML_HOST ::= "fecc-117-194-127-176.ngrok.io"
DAML_PATH ::= "/v1/create"

MAP_HOST ::= "ip-api.com"
MAP_PATH ::= "/json/"

/// The GPIO pin the button is connected to.
SEALPIN ::= 12

network ::= net.open
state := 0

decoder := null
response := null
api_request := null
connection := null
request := null
content := {}
socket := null
location := null
j:= null
event_msg := " "
counter := 0

driver := null
seal ::= gpio.Pin SEALPIN --input --pull_up
bus := i2c.Bus
  --sda=gpio.Pin 21
  --scl=gpio.Pin 22
device := bus.device bme280.I2C_ADDRESS_ALT

main:
  state = seal.get
  // if the seal is open run this block and stops sending events forever after two attempts
  if state == 1 and counter < 2:
    location = get_location --https=false
    print location["lat"]
    print location["lon"]
    sleep --ms=5000

    driver = bme280.Driver device
    print "$driver.read_temperature C"
    print "$driver.read_pressure Pa"
    print "$driver.read_humidity %"
    sleep --ms=5000

    print "Packet Opened"
    event_msg = "Packet Opened. Seal Broken"
    track_package --https=false location["lat"] location["lon"] driver.read_temperature driver.read_pressure driver.read_humidity event_msg
    sleep --ms= 1000 * 10
    // to maintain user's privacy the device stops after sending final data event twice
    counter = counter + 1
  else:
    location = get_location --https=false
    print location["lat"]
    print location["lon"]
    sleep --ms=5000

    driver = bme280.Driver device
    print "$driver.read_temperature C"
    print "$driver.read_pressure Pa"
    print "$driver.read_humidity %"
    sleep --ms=5000

    print "Packet Not Opened"
    event_msg = "Packet Not Opened. Seal Closed"
    track_package --https=false location["lat"] location["lon"] driver.read_temperature driver.read_pressure driver.read_humidity event_msg
    // send message every 12 hours, entering sleep to save power, and then waking up to send message
    // to modify the message rate, change the on_interval papramter in YAML deployment file
    sleep --ms= 1000 * 10

get_location --https/bool=true:
  // Make a TCP connection to the server port on localhost.
  socket = network.tcp_connect MAP_HOST (https ? 443 : 80)
  if https:
    // Put a TLS socket on the TCP connection
    socket = tls.Socket.client socket
      --server_name=MAP_HOST
      --root_certificates=[certificate_roots.ISRG_ROOT_X1]
  try:
    // Create an HTTP connection on the TLS connection.
    connection = http.Connection socket MAP_HOST
    // Make a GET request.
    api_request = connection.new_request "GET" MAP_PATH
    response = api_request.send
    decoder = json.StreamingDecoder
    j = decoder.decode_stream response
  finally:
    socket.close
  return j


track_package --https/bool=true lat/float=0.0 lon/float=0.0 temperature/float=0.0 pressure/float=0.0 humidity/float=0.0 event_msg/string="":

  // Make a TCP connection to the server port on localhost.
  socket = network.tcp_connect DAML_HOST (https ? 443 : 80)
  if https:
    // Put a TLS socket on the TCP connection
    socket = tls.Socket.client socket
      --server_name=DAML_HOST
      --root_certificates=[certificate_roots.ISRG_ROOT_X1]
  try:
    // Create an HTTP connection on the TLS connection.
    connection = http.Connection socket DAML_HOST
    // Make a POST request.
    request = connection.new_request "POST" DAML_PATH
    request.headers.add "Authorization" "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwczovL2RhbWwuY29tL2xlZGdlci1hcGkiOnsibGVkZ2VySWQiOiJ0ZXN0LXNhbmRib3giLCJhcHBsaWNhdGlvbklkIjoibm9uZSIsImFjdEFzIjpbIlRyYWNrZXIxIl19fQ.wwOxnjlQJM09kVs5XjahEboq8khw9ScTL7i2YWgI3VE"
    content = {
      "payload": {
                  "device": "Tracker1",
                  "regulator": "Bayer",
                  "location": {
                    "long": "$lon",
                    "lat": "$lat"
                  },
                  "temperature": "$temperature",
                  "humidity": "$humidity",
                  "pressure": "$pressure",
                  "productDetails": {
                      "product_name": "Celsius WG",
                      "product_type": "Herbicide",
                      "product_price": "150.0",
                      "product_quantity": "250"
                  },
                  "timestamp": "$Time.now.utc.to_iso8601_string",
                  "event": "$event_msg"
      },
      "templateId": "89b539f57f33ab841ebd56b0e91167efe26c8a402a3d181e8f1acaa717312387:LabelRecord:Label_Tracking"
    }
    request.body = json.encode content
    response = request.send
    // Read the response:
    decoder = json.decode_stream response
    print decoder
  finally:
    connection.close
