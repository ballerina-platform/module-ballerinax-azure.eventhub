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
import ballerina/log;

ClientEndpointConfiguration config = {
    sasKeyName: getConfigValue("SAS_KEY_NAME"),
    sasKey: getConfigValue("SAS_KEY"),
    resourceUri: getConfigValue("RESOURCE_URI")
};
Client c = <Client>new Client(config);

// Test functions
@test:Config {
    enable: false
}
function testBatchEventError() {
    map<string> brokerProps = {CorrelationId: "32119834", CorrelationId2: "32119834"};
    map<string> userProps = {Alert: "windy", warning: "true"};

    BatchEvent batchEvent = {
        events: [
                {data: "Message1"},
                {data: "Message2", brokerProperties: brokerProps},
                {data: "Message3", brokerProperties: brokerProps, userProperties: userProps}
            ]
    };
    var b = c->sendBatch("myeventhub", batchEvent);
    if (b is error) {
        test:assertFail(msg = b.message());
    }
    test:assertTrue(b is ());
}

@test:Config {
    enable: false
}
function testSendEvent() {
    var b = c->send("myeventhub", "eventData");
    if (b is error) {
        test:assertFail(msg = b.message());
    }
    test:assertTrue(b is ());
}

@test:Config {
    enable: false
}
function testSendEventWithBrokerAndUserProperties() {
    map<string> brokerProps = {"CorrelationId": "32119834", "CorrelationId2": "32119834"};
    map<string> userProps = {Alert: "windy", warning: "true"};

    var b = c->send("myeventhub", "eventData", userProps, brokerProps);
    if (b is error) {
        test:assertFail(msg = b.message());
    }
    test:assertTrue(b is ());
}

@test:Config {
    enable: false
}
function testSendPartitionEvent() {
    map<string> brokerProps = {CorrelationId: "32119834", CorrelationId2: "32119834"};
    map<string> userProps = {Alert: "windy", warning: "true"};

    var b = c->send("myeventhub", "data", userProps, brokerProps, partitionId=1);
    if (b is error) {
        test:assertFail(msg = b.message());
    }
    test:assertTrue(b is ());
}

@test:Config {
    enable: false
}
function testSendBatchEvent() {
    map<string> brokerProps = {CorrelationId: "32119834", CorrelationId2: "32119834"};
    map<string> userProps = {Alert: "windy", warning: "true"};

    BatchEvent batchEvent = {
        events: [
            {data: "Message1"},
            {data: "Message2", brokerProperties: brokerProps},
            {data: "Message3", brokerProperties: brokerProps, userProperties: userProps}
        ]
    };
    var b = c->sendBatch("myeventhub", batchEvent);
    if (b is error) {
        test:assertFail(msg = b.message());
    }
    test:assertTrue(b is ());
}

@test:Config {
    enable: false
}
function testSendBatchEventToPartition() {
    map<string> brokerProps = {CorrelationId: "32119834", CorrelationId2: "32119834"};
    map<string> userProps = {Alert: "windy", warning: "true"};

    BatchEvent batchEvent = {
        events: [
            {data: "Message1"},
            {data: "Message2", brokerProperties: brokerProps},
            {data: "Message3", brokerProperties: brokerProps, userProperties: userProps}
        ]
    };
    var b = c->sendBatch("myeventhub", batchEvent, partitionId=1);
    if (b is error) {
        test:assertFail(msg = b.message());
    }
    test:assertTrue(b is ());
}

@test:Config {
    enable: false
}
function testSendBatchEventWithPublisherID() {
    map<string> brokerProps = {CorrelationId: "32119834", CorrelationId2: "32119834"};
    map<string> userProps = {Alert: "windy", warning: "true"};

    BatchEvent batchEvent = {
        events: [
            {data: "Message1"},
            {data: "Message2", brokerProperties: brokerProps},
            {data: "Message3", brokerProperties: brokerProps, userProperties: userProps}
        ]
    };
    var b = c->sendBatch("myeventhub", batchEvent, publisherId="device-1");
    if (b is error) {
        test:assertFail(msg = b.message());
    }
    test:assertTrue(b is ());
}

@test:Config {
    enable: false
}
function testCreateEventHub() {
    var b = c->createEventHub("myhub");
    if (b is error) {
        test:assertFail(msg = b.message());
    }
    test:assertTrue(b is xml);
    if (b is xml) {
        log:print(b.toString());
    }
}

@test:Config {
    enable: false
}
function testGetEventHub() {
    var b = c->getEventHub("myhub");
    if (b is error) {
        test:assertFail(msg = b.message());
    }
    test:assertTrue(b is xml);
    if (b is xml) {
        log:print(b.toString());
    }
}

// TODO:Fix updateEventHub logic
@test:Config {
    enable: false
}
function testUpdateEventHub() {
    EventHubDescriptionToUpdate eventHubDescriptionToUpdate = {
        messageRetentionInDays: 5
    };
    var b = c->updateEventHub("myhub", eventHubDescriptionToUpdate);
    if (b is error) {
        test:assertFail(msg = b.message());
    }
    test:assertTrue(b is xml);
    if (b is xml) {
        log:print(b.toString());
    }
}

@test:Config {
    enable: false
}
function testListEventHubs() {
    var b = c->listEventHubs();
    if (b is error) {
        test:assertFail(msg = b.message());
    }
    test:assertTrue(b is xml);
    if (b is xml) {
        log:print("listReceived");
    }
}

@test:Config {
    enable: false
}
function testDeleteEventHub() {
    var b = c->deleteEventHub("myhub");
    if (b is error) {
        test:assertFail(msg = b.message());
    }
    test:assertTrue(b is ());
}

@test:Config {
    enable: false
}
function testGetRevokedPublishers() {
    var b = c->getRevokedPublishers("myeventhub");
    if (b is error) {
        test:assertFail(msg = b.message());
    }
    test:assertTrue(b is xml);
    if (b is xml) {
        log:print(b.toString());
    }
}

// TODO:Fix revokePublisher logic
@test:Config {
    enable: false
}
function testRevokePublisher() {
    var b = c->revokePublisher("myeventhub", "device-1");
    if (b is error) {
        test:assertFail(msg = b.message());
    }
    test:assertTrue(b is xml);
    if (b is xml) {
        log:print(b.toString());
    }
}

@test:Config {
    enable: false
}
function testResumePublisher() {
    var b = c->resumePublisher("myeventhub", "device-1");
    if (b is error) {
        test:assertFail(msg = b.message());
    }
    test:assertTrue(b is ());
    if (b is ()) {
        log:print("successful");
    }
}

@test:Config {
    enable: false
}
function testCreateConsumerGroup() {
    var b = c->createConsumerGroup("myeventhub","consumerGroup1");
    if (b is error) {
        test:assertFail(msg = b.message());
    }
    test:assertTrue(b is xml);
    if (b is xml) {
        log:print(b.toString());
    }
}

@test:Config {
    enable: false
}
function testGetConsumerGroup() {
    var b = c->getConsumerGroup("myeventhub", "consumerGroup1");
    if (b is error) {
        test:assertFail(msg = b.message());
    }
    test:assertTrue(b is xml);
    if (b is xml) {
        log:print(b.toString());
    }
}

@test:Config {
    enable: false
}
function testListConsumerGroups() {
    var b = c->listConsumerGroups("myeventhub");
    if (b is error) {
        test:assertFail(msg = b.message());
    }
    test:assertTrue(b is xml);
    if (b is xml) {
        log:print("successful");
    }
}

@test:Config {
    enable: false
}
function testListPartitions() {
    var b = c->listPartitions("myeventhub", "consumerGroup1");
    if (b is error) {
        test:assertFail(msg = b.message());
    }
    test:assertTrue(b is xml);
    if (b is xml) {
        log:print("successful");
    }
}

@test:Config {
    enable: true
}
function testGetPartition() {
    var b = c->getPartition("myeventhub", "consumerGroup1", 1);
    if (b is error) {
        test:assertFail(msg = b.message());
    }
    test:assertTrue(b is xml);
    if (b is xml) {
        log:print(b.toString());
    }
}

@test:Config {
    enable: false
}
function testDeleteConsumerGroups() {
    var b = c->deleteConsumerGroup("myeventhub","consumerGroup1");
    if (b is error) {
        test:assertFail(msg = b.message());
    }
    test:assertTrue(b is ());
    if (b is ()) {
        log:print("successful");
    }
}

# Get configuration value for the given key from ballerina.conf file.
# 
# + return - configuration value of the given key as a string
isolated function getConfigValue(string key) returns string {
    return (system:getEnv(key) != "") ? system:getEnv(key) : config:getAsString(key);
}
