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

import ballerina/test;
import ballerina/os;
import ballerina/log;

configurable string sasKeyName = os:getEnv("SAS_KEY_NAME");
configurable string sasKey = os:getEnv("SAS_KEY");
configurable string resourceUri = os:getEnv("RESOURCE_URI");

ConnectionConfig config = {
    sasKeyName: sasKeyName,
    sasKey: sasKey,
    resourceUri: resourceUri 
};

Client managementClient = checkpanic new (config);
Client publisherClient = checkpanic new (config);

var randomString = createRandomUUIDWithoutHyphens();

string event_hub_name1 = string `eventhubname1_${randomString.toString()}`;
string event_hub_name2 = string `eventhubname2_${randomString.toString()}`;
string event_hub_name3 = string `eventhubname3_${randomString.toString()}`;

# Before Suite Function
@test:BeforeSuite
function beforeSuiteFunc() {
    EventHub|error result = managementClient->createEventHub(event_hub_name1);
    if (result is error) {
        test:assertFail(msg = result.message());
    } else {
        log:printInfo("EventHub created successfully!");
        log:printInfo(result.toString());
    }
}

@test:Config {
    groups: ["eventhub"],
    enable: true
}
function testSendEvent() {
    error? result = publisherClient->send(event_hub_name1, "eventData");
    if (result is error) {
        test:assertFail(msg = result.message());
    }
    log:printInfo("Event sent successfully!");
}

@test:Config {
    groups: ["eventhub"],
    enable: true
}
function testSendEventWithBrokerAndUserProperties() {
    map<string> brokerProps = {"CorrelationId": "32119834", "CorrelationId2": "32119834"};
    map<string> userProps = {Alert: "windy", warning: "true"};

    error? result = publisherClient->send(event_hub_name1, "eventData", userProps, brokerProps);
    if (result is error) {
        test:assertFail(msg = result.message());
    }
    log:printInfo("Event sent with broker & user properties successfully!");
}

@test:Config {
    groups: ["eventhub"],
    enable: true
}
function testSendEventWithPartitionKey() {
    map<string> brokerProps = {PartitionKey: "groupName1", CorrelationId: "32119834"};
    map<string> userProps = {Alert: "windy", warning: "true"};

    error? result = publisherClient->send(event_hub_name1, "data", userProps, brokerProps, partitionKey = "groupName");
    if (result is error) {
        test:assertFail(msg = result.message());
    }
    log:printInfo("Event sent with partition key successfully!");
}

@test:Config {
    groups: ["eventhub"],
    enable: true
}
function testSendEventToPartition() {
    map<string> brokerProps = {CorrelationId: "32119834", CorrelationId2: "32119834"};
    map<string> userProps = {Alert: "windy", warning: "true"};

    error? result = publisherClient->send(event_hub_name1, "data", userProps, brokerProps, partitionId = 1);
    if (result is error) {
        test:assertFail(msg = result.message());
    }
    log:printInfo("Event sent to partition successfully!");
}

@test:Config {
    groups: ["eventhub"],
    enable: true
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
    error? result = publisherClient->sendBatch(event_hub_name1, batchEvent);
    if (result is error) {
        test:assertFail(msg = result.message());
    }
    log:printInfo("Batch event sent successfully!");
}

@test:Config {
    groups: ["eventhub"],
    enable: true
}
function testSendBatchEventWithPartitionKey() {
    map<string> brokerProps = {PartitionKey: "groupName", CorrelationId: "32119834"};
    map<string> userProps = {Alert: "windy", warning: "true"};

    BatchEvent batchEvent = {
        events: [
            {data: "Message1"},
            {data: "Message2", brokerProperties: brokerProps},
            {data: "Message3", brokerProperties: brokerProps, userProperties: userProps}
        ]
    };
    error? result = publisherClient->sendBatch(event_hub_name1, batchEvent, partitionKey = "groupName");
    if (result is error) {
        test:assertFail(msg = result.message());
    }
    log:printInfo("Batch event sent with partition key successfully!");
}

@test:Config {
    groups: ["eventhub"],
    enable: true
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
    error? result = publisherClient->sendBatch(event_hub_name1, batchEvent, partitionId = 1);
    if (result is error) {
        test:assertFail(msg = result.message());
    }
    log:printInfo("Batch event sent to partition successfully!");
}

@test:Config {
    groups: ["eventHubManagment"],
    enable: true
}
function testCreateEventHub() {
    EventHub|error result = managementClient->createEventHub(event_hub_name2);
    if (result is error) {
        test:assertFail(msg = result.message());
    } else {
        log:printInfo("EventHub created successfully!");
        log:printInfo(result.toString());
    }
}

@test:Config {
    groups: ["eventHubManagment"],
    dependsOn: [testCreateEventHub],
    enable: true
}
function testGetEventHub() {
    EventHub|error result = managementClient->getEventHub(event_hub_name2);
    if (result is error) {
        test:assertFail(msg = result.message());
    } else {
        log:printInfo("EventHub received successfully!");
        log:printInfo(result.toString());
    }
}

@test:Config {
    groups: ["eventHubManagment"],
    dependsOn: [testCreateEventHub],
    enable: true
}
function testUpdateEventHub() {
    EventHubDescriptionToUpdate eventHubDescriptionToUpdate = {
        MessageRetentionInDays: 5
    };
    EventHub|error result = managementClient->updateEventHub(event_hub_name2, eventHubDescriptionToUpdate);
    if (result is error) {
        test:assertFail(msg = result.message());
    } else {
        log:printInfo("EventHub updated successfully!");
        log:printInfo(result.toString());
    }
}

//TODO: Fix xml returned cannot be converted to string
@test:Config {
    groups: ["eventHubManagment"],
    dependsOn: [testCreateEventHub],
    enable: true
}
function testListEventHubs() {
    stream<EventHub>|error result = managementClient->listEventHubs();
    if (result is error) {
        test:assertFail(msg = result.message());
    } else {
        log:printInfo("EventHub list received successfully!");
        _ = result.forEach(isolated function (EventHub eventHub) {
                log:printInfo(eventHub.toString());
            });
    }
}

@test:Config {
    groups: ["eventHubManagment"],
    dependsOn: [
        testCreateEventHub,
        testGetEventHub,
        testUpdateEventHub,
        testListEventHubs
    ],
    enable: true
}
function testDeleteEventHub() {
    error? result = managementClient->deleteEventHub(event_hub_name2);
    if (result is error) {
        test:assertFail(msg = result.message());
    }
    log:printInfo("EventHub deleted successfully!");
}

@test:Config {
    groups: ["eventHubManagment"],
    dependsOn: [testDeleteEventHub],
    enable: true
}
function testCreateEventHubWithEventHubDescription() {
    EventHubDescription eventHubDescription = {
        MessageRetentionInDays: 3,
        PartitionCount: 8
    };
    EventHub|error result = managementClient->createEventHub(event_hub_name3, eventHubDescription);
    if (result is error) {
        test:assertFail(msg = result.message());
    } else {
        log:printInfo("EventHub created with EventHub description successfully!");
        log:printInfo(result.toString());
    }
}

@test:Config {
    groups: ["eventHubManagment"],
    dependsOn: [testCreateEventHubWithEventHubDescription],
    enable: true
}
function testDeleteEventHubWithEventHubDescription() {
    error? result = managementClient->deleteEventHub(event_hub_name3);
    if (result is error) {
        test:assertFail(msg = result.message());
    }
    log:printInfo("EventHub created with EventHub description deleted successfully!");
}

@test:Config {
    groups: ["publisher"],
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
    error? result = publisherClient->sendBatch(event_hub_name1, batchEvent, publisherId = "device-1");
    if (result is error) {
        test:assertFail(msg = result.message());
    }
    log:printInfo("Batch event with publisher ID sent successfully!");
}

@test:Config {
    groups: ["publisher"],
    enable: true
}
function testRevokePublisher() {
    RevokePublisher|error result = publisherClient->revokePublisher(event_hub_name1, "device-1");
    if (result is error) {
        test:assertFail(msg = result.message());
    } else {
        log:printInfo("Publisher revoked successfully!");
        log:printInfo(result.toString());
    }
}

@test:Config {
    enable: false
}
function testSendEventWithPublisherID() {
    map<string> brokerProps = {CorrelationId: "32119834", CorrelationId2: "32119834"};
    map<string> userProps = {Alert: "windy", warning: "true"};

    error? result = publisherClient->send(event_hub_name1, "data", userProps, brokerProps, publisherId = "device-1");
    if (result is error) {
        test:assertFail(msg = result.message());
    }
    log:printInfo("Event with publisher ID sent successfully!");
}

//TODO: xml returned cannot be converted to string
@test:Config {
    groups: ["publisher"],
    dependsOn: [testRevokePublisher],
    enable: true
}
function testGetRevokedPublishers() {
    stream<RevokePublisher>|error result = publisherClient->getRevokedPublishers(event_hub_name1);
    if (result is error) {
        test:assertFail(msg = result.message());
    } else {
        log:printInfo("Revoked publishers list received successfully!");
        _ = result.forEach(isolated function (RevokePublisher revokePublisher) {
                log:printInfo(revokePublisher.toString());
            });
    }
}

@test:Config {
    groups: ["publisher"],
    dependsOn: [
        testRevokePublisher,
        testGetRevokedPublishers
    ],
    enable: true
}
function testResumePublisher() {
    error? result = publisherClient->resumePublisher(event_hub_name1, "device-1");
    if (result is error) {
        test:assertFail(msg = result.message());
    }
    log:printInfo("Publisher resumed successfully!");
}

@test:Config {
    groups: ["consumergroup"],
    enable: true
}
function testCreateConsumerGroup() {
    ConsumerGroup|error result = managementClient->createConsumerGroup(event_hub_name1, "consumerGroup1");
    if (result is error) {
        test:assertFail(msg = result.message());
    } else {
        log:printInfo("ConsumerGroup created successfully!");
        log:printInfo(result.toString());
    }
}

@test:Config {
    groups: ["consumergroup"],
    dependsOn: [testCreateConsumerGroup],
    enable: true
}
function testGetConsumerGroup() {
    ConsumerGroup|error result = managementClient->getConsumerGroup(event_hub_name1, "consumerGroup1");
    if (result is error) {
        test:assertFail(msg = result.message());
    } else {
        log:printInfo("ConsumerGroup received successfully!");
        log:printInfo(result.toString());
    }
}

@test:Config {
    groups: ["consumergroup"],
    dependsOn: [testCreateConsumerGroup],
    enable: true
}
function testListConsumerGroups() {
    stream<ConsumerGroup>|error result = managementClient->listConsumerGroups(event_hub_name1);
    if (result is error) {
        test:assertFail(msg = result.message());
    } else {
        log:printInfo("ConsumerGroup list received successfully!");
        _ = result.forEach(isolated function (ConsumerGroup consumerGroup) {
                log:printInfo(consumerGroup.toString());
            });
    }
}

@test:Config {
    groups: ["consumergroup"],
    dependsOn: [testCreateConsumerGroup],
    enable: true
}
function testListPartitions() {
    stream<Partition>|error result = managementClient->listPartitions(event_hub_name1, "consumerGroup1");
    if (result is error) {
        test:assertFail(msg = result.message());
    } else {
        log:printInfo("Partitions list received successfully!");
        _ = result.forEach(isolated function (Partition partition) {
                log:printInfo(partition.toString());
            });
    }
}

@test:Config {
    groups: ["consumergroup"],
    dependsOn: [testCreateConsumerGroup],
    enable: true
}
function testGetPartition() {
    Partition|error result = managementClient->getPartition(event_hub_name1, "consumerGroup1", 1);
    if (result is error) {
        test:assertFail(msg = result.message());
    } else {
        log:printInfo("Partition received successfully!");
        log:printInfo(result.toString());
    }
}

@test:Config {
    groups: ["consumergroup"],
    dependsOn: [
        testCreateConsumerGroup,
        testGetConsumerGroup,
        testListConsumerGroups,
        testListPartitions,
        testGetPartition
    ],
    enable: true
}
function testDeleteConsumerGroups() {
    error? result = managementClient->deleteConsumerGroup(event_hub_name1, "consumerGroup1");
    if (result is error) {
        test:assertFail(msg = result.message());
    } else {
        log:printInfo("ConsumerGroup deleted successfully!");
    }
}

# After Suite Function
@test:AfterSuite {}
function afterSuiteFunc() {
    error? result = managementClient->deleteEventHub(event_hub_name1);
    if (result is error) {
        test:assertFail(msg = result.message());
    }
    log:printInfo("EventHub deleted successfully!");
}

// # Get configuration value for the given key from ballerina.conf file.
// # 
// # + return - configuration value of the given key as a string
// isolated function getConfigValue(string key) returns string {
//     return (os:getEnv(key) != "") ? os:getEnv(key) : config:getAsString(key);
// }
