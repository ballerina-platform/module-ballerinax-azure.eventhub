// Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/test;
import ballerina/config;
import ballerina/system;

// Test functions
@test:Config {}
function testBatchEventError() {
    ClientEndpointConfiguration config = {
        sasKeyName: getConfigValue("SAS_KEY_NAME"),
        sasKey: getConfigValue("SAS_KEY"),
        resourceUri: getConfigValue("RESOURCE_URI")
    };
    Client c = <Client>new Client(config);
    map<string> brokerProps = {CorrelationId: "32119834", CorrelationId2: "32119834"};
    map<string> userProps = {Alert: "windy", warning: "true"};

    BatchEvent batchEvent = {
        events: [
                {data: "Message1"},
                {data: "Message2", brokerProperties: brokerProps},
                {data: "Message3", brokerProperties: brokerProps, userProperties: userProps}
            ]
    };
    var b = c->sendBatch("myhub", batchEvent);
    test:assertTrue(b is error);
    if (b is error) {
        test:assertExactEquals(b.message(), "error invoking EventHub API ");
    }
}

# Get configuration value for the given key from ballerina.conf file.
# 
# + return - configuration value of the given key as a string
isolated function getConfigValue(string key) returns string {
    return (system:getEnv(key) != "") ? system:getEnv(key) : config:getAsString(key);
}
