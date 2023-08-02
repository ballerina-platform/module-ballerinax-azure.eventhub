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

import ballerinax/azure.eventhub;
import ballerina/log;

configurable string sasKeyName = ?;
configurable string sasKey = ?;
configurable string resourceUri = ?;

public function main() {
    eventhub:ConnectionConfig config = {
        sasKeyName: sasKeyName,
        sasKey: sasKey,
        resourceUri: resourceUri 
    };
    eventhub:Client publisherClient = checkpanic new (config);

    map<string> brokerProps = {CorrelationId: "32119834", CorrelationId2: "32119834"};
    map<string> userProps = {Alert: "windy", warning: "true"};

    eventhub:BatchEvent batchEvent = {
        events: [
            {data: "Message1"},
            {data: "Message2", brokerProperties: brokerProps},
            {data: "Message3", brokerProperties: brokerProps, userProperties: userProps}
        ]
    };
    var result = publisherClient->sendBatch("myeventhub", batchEvent);
    if (result is error) {
        log:printError(result.message());
    } else {
        log:printInfo("Successful!");
    }
}
