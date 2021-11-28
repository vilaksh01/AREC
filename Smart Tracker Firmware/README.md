# Smart Trackable Label
#### The smart tracking label is an unqiue way to make agricultural products transportation safer and free from counterfeits. With product traceability (localization and expected delivery date- information flow from farmer Bayer to customers), hardware-based traceability is much better than relying on humans. 
1. Provides product security, or anti-counterfeiting – Making sure that the product is not forged/Copied and is an original Bayer product 
2. Almost impossible with our solution since Device ID is the only way to connect to the Blockchain ledger and no duplicates can persist, even if Device ID barcode is copied still it won't allow the device unless past track of it's logistics data is available

### Step 1: Physical Label Layout
![image](https://user-images.githubusercontent.com/44412828/143776804-d18565d9-b157-44a7-be2a-b49c64bb2e79.png)
Using the above layout provided me enough flexibility to cover a wider range of Bayer products, also to keep things simple only most relevant details for the farmers are placed on the label, for example.. farmers don't look to all details of the product like manufacturing process, company's info, etc. we should emphasize on those details which should not be missed. Since there's always an improved version of product from bayer for farmer that too can be covered in above layout.

### Step 2: Printing the physical label
![sticky_label](https://user-images.githubusercontent.com/44412828/143777752-510456c9-2e66-4cb3-8413-fa51bcbb968e.jpg)
I got the label printed on A4 size sticky paper to make first prototype.

### Step 3: Building smart tracking circuit on the label
<img src="https://user-images.githubusercontent.com/44412828/143777260-804cf60f-97df-42c6-9dba-930bc9d3979d.jpg" width="33%" height="500">|<img src="https://user-images.githubusercontent.com/44412828/143777265-2dce353a-1f56-4cb9-998d-02170ccc6871.jpg" width="33%" height="500">|<img src="https://user-images.githubusercontent.com/44412828/143777267-e4a5a3e8-a165-4f30-814e-42e53b8d30f9.jpg" width="33%" height="500">
The devices used are ESP32, BME280 and CCS811 sensors, copper tape and thin 200 mA LiPo battery. The choice of the hardware is due to cheap price of ESP32($3) thus it can be easily manufactured on printed PCBs for such smart label applications. Also, for connectivity I am focused on LTE-M since it is easily available in most countries and sooner cheaper LTE modems would be available for such applications. LoRa was another choice here but it is not good for globally moving assets.

### Step 4: Working of the Smart Label Tracker
![image](https://user-images.githubusercontent.com/44412828/143778327-de745cb0-4d4b-48c5-b014-8ef5688153da.png)

### Step 5: Uploading the Toit firmware on the device
Firstly make a Toit account and install toit SDK check here: 
1. https://docs.toit.io/getstarted
2. https://docs.toit.io/getstarted/installation
3. https://pkg.toit.io/
4. Use command ```toit deploy --device device_name script.yaml``` to deploy the app on toit
