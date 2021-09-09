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
    azure_eventhub:ConnectionConfig config = {
        sasKeyName: sasKeyName,
        sasKey: sasKey,
        resourceUri: resourceUri 
    };
    azure_eventhub:Client managementClient = checkpanic new (config);
    azure_eventhub:Client publisherClient = checkpanic new (config);

    // ------------------------------------ Event Hub Creation-----------------------------------------------
    azure_eventhub:EventHubDescription eventHubDescription = {
        MessageRetentionInDays: 3,
        PartitionCount: 8
    };
    var createResult = managementClient->createEventHub("mytesthub", eventHubDescription);
    if (createResult is error) {
        log:printError(createResult.message());
    }
    if (createResult is azure_eventhub:EventHub) {
        log:printInfo(createResult.toString());
        log:printInfo("Successfully Created Event Hub!");
    }

    // ----------------------------------------- Send Event ------------------------------------------------
    map<string> brokerProps = {CorrelationId: "32119834", CorrelationId2: "32119834"};
    map<string> userProps = {Alert: "windy", warning: "true"};

    var sendResult = publisherClient->send("mytesthub", "eventData", userProps, brokerProps, 
        partitionKey = "groupName");
    if (sendResult is error) {
        log:printError(sendResult.message());
    } else {
        log:printInfo("Successfully Send Event to Event Hub!");
    }

    // ------------------------------- Send Batch Event with Partition Key -----------------------------------------
    azure_eventhub:BatchEvent batchEvent = {
        events: [
            {data: "Message1"},
            {data: "Message2", brokerProperties: brokerProps},
            {data: "Message3", brokerProperties: brokerProps, userProperties: userProps}
        ]
    };
    var sendBatchResult = publisherClient->sendBatch("mytesthub", batchEvent, partitionKey = "groupName");
    if (sendBatchResult is error) {
        log:printError(sendBatchResult.message());
    } else {
        log:printInfo("Successfully Send Batch Event to Event Hub!");
    } 

    // --------------------------------- Delete Event Hub ----------------------------------------------------
    var deleteResult = managementClient->deleteEventHub("mytesthub");
    if (deleteResult is error) {
        log:printError(msg = deleteResult.message());
    } else {
        log:printInfo("Successfully Deleted Event Hub!");
    }    
}
