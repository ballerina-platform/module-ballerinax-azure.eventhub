// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerinax/azure_eventhub;
import ballerina/log;

configurable string sasKeyName = ?;
configurable string sasKey = ?;
configurable string resourceUri = ?;

public function main() {
    azure_eventhub:ClientEndpointConfiguration config = {
        sasKeyName: sasKeyName,
        sasKey: sasKey,
        resourceUri: resourceUri 
    };
    azure_eventhub:ManagementClient managementClient = checkpanic new (config);

    // ------------------------------------ Event Hub Creation-----------------------------------------------
    var createResult = managementClient->createEventHub("mytesthub");
    if (createResult is error) {
        log:printError(createResult.message());
    }
    if (createResult is xml) {
        log:print(createResult.toString());
        log:print("Successfully Created Event Hub!");
    }

    // ----------------------------------- Get Event Hub -----------------------------------------------------
    var getEventHubResult = managementClient->getEventHub("mytesthub");
    if (getEventHubResult is error) {
        log:printError(getEventHubResult.message());
    }
    if (getEventHubResult is xml) {
        log:print(getEventHubResult.toString());
        log:print("Successfully Get Event Hub!");
    } 

    // --------------------------------- Update Event Hub --------------------------------------------------
    azure_eventhub:EventHubDescriptionToUpdate eventHubDescriptionToUpdate = {
        MessageRetentionInDays: 5
    };
    var updateResult = managementClient->updateEventHub("mytesthub", eventHubDescriptionToUpdate);
    if (updateResult is error) {
        log:printError(updateResult.message());
    }
    if (updateResult is xml) {
        log:print(updateResult.toString());
        log:print("Successfully Updated Event Hub!");
    }

    // ---------------------------------- List Event Hubs -----------------------------------------------------
    var listResult = managementClient->listEventHubs();
    if (listResult is error) {
        log:printError(listResult.message());
    }
    if (listResult is xml) {
        log:print(listResult.toString());
        log:print("Successfully Listed Event Hubs!");
    }

    // --------------------------------- Delete Event Hub ----------------------------------------------------
    var deleteResult = managementClient->deleteEventHub("mytesthub");
    if (deleteResult is error) {
        log:printError(msg = deleteResult.message());
    } else {
        log:print("Successfully Deleted Event Hub!");
    }    
}