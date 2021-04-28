// Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/lang.'int;
import ballerina/lang.'xml as xmllib;
import ballerina/xmldata;

# Convert batch event to json
#
# + batchEvent - batch event 
# + return - Return eventhub formatted json
isolated function getBatchEventJson(BatchEvent batchEvent) returns json {
    json[] message = [];
    foreach var item in batchEvent.events {
        json data = checkpanic item.data.cloneWithType(json);
        json jsonMessage = {
            Body: data
        };
        if (!(item["userProperties"] is ())) {
            json userProperties = {UserProperties:checkpanic item["userProperties"].cloneWithType(json)};
            jsonMessage = checkpanic jsonMessage.mergeJson(userProperties);
        }
        if (!(item["brokerProperties"] is ())) {
            json brokerProperties = {BrokerProperties:checkpanic item["brokerProperties"].cloneWithType(json)};
            jsonMessage = checkpanic jsonMessage.mergeJson(brokerProperties);
        }
        message.push(jsonMessage);
    }
    return message;
}

# Convert eventhub description to xml
#
# + descriptionProperties - eventhub or consumer group description
# + return - Return eventhub formatted json
isolated function getDescriptionProperties(EventHubDescription|EventHubDescriptionToUpdate|ConsumerGroupDescription|
                                           RevokePublisherDescription? descriptionProperties, 
                                           xmllib:Element description) returns xml {
    json descriptionJson;
    if (descriptionProperties is ()) {
        descriptionJson = {};
    } else {
        descriptionJson = checkpanic descriptionProperties.cloneWithType(json);
    }
    xml eventHubDescriptionXml = <xml> checkpanic xmldata:fromJson(descriptionJson);
    xmllib:Element entry = <xmllib:Element> xml `<entry xmlns='http://www.w3.org/2005/Atom'/>`;
    xmllib:Element content = <xmllib:Element> xml `<content type='application/xml'/>`;
    description.setChildren(eventHubDescriptionXml);
    content.setChildren(description);
    entry.setChildren(content);
    return entry;
}

# Convert xml content to EventHub stream
#
# + xmlPayload - xml content
# + return - Return EventHub stream or error
isolated function mapToEventHubStream(xml xmlPayload) returns stream<EventHub>|error {
    xmlns "http://www.w3.org/2005/Atom";
    EventHub[] eventHubs = [];
    xml entries = xmlPayload/<entry>;
    foreach xml entry in entries {
        EventHub eventHub = {};
        eventHub = check mapXmlToEventHubRecord(entry);
        eventHubs.push(eventHub);
    }
    return eventHubs.toStream();
}

# Convert xml content to EventHub record
#
# + xmlContent - xml content
# + return - Return EventHub record or error
isolated function mapXmlToEventHubRecord(xml xmlContent) returns EventHub|error {
    xmlns "http://www.w3.org/2005/Atom";
    EventHub eventHub = {};
    json idElementEH = check xmldata:toJson(xmlContent/<id>);
    json idEH = check idElementEH.id.id; 
    eventHub.id = idEH.toString();
    json titleElementEH = check xmldata:toJson(xmlContent/<title>);
    json titleEH = check titleElementEH.title.title; 
    eventHub.title = titleEH.toString();
    json publishedElementEH = check xmldata:toJson(xmlContent/<published>);
    json publishedEH = check publishedElementEH.published.published;
    eventHub.published = publishedEH.toString();
    json updatedElementEH = check xmldata:toJson(xmlContent/<updated>);
    json updatedEH = check updatedElementEH.updated.updated;
    eventHub.updated = updatedEH.toString();
    json authorElementEH = check xmldata:toJson(xmlContent/<author>/<name>);
    json authorEH = check authorElementEH.name.name;
    eventHub.authorName = authorEH.toString();
    xml content = xmlContent/<content>;
    EventHubDescription eventHubDescription = {};
    eventHubDescription = check mapXmlToEventHubDescriptionRecord(content);
    eventHub.eventHubDescription = eventHubDescription;
    return eventHub;
}

# Convert xml content to EventHubDescription record
#
# + xmlContent - xml content
# + return - Return EventHubDescription record or error
isolated function mapXmlToEventHubDescriptionRecord(xml xmlContent) returns EventHubDescription|error {
    xmlns "http://schemas.microsoft.com/netservices/2010/10/servicebus/connect";
    xml description = xmlContent/<EventHubDescription>;
    EventHubDescription eventHubDescription = {};
    json MessageRetentionInDaysElement = check xmldata:toJson(description/<MessageRetentionInDays>);
    json MessageRetention = check MessageRetentionInDaysElement.MessageRetentionInDays.MessageRetentionInDays;
    eventHubDescription.MessageRetentionInDays = check int:fromString(MessageRetention.toString());
    json StatusElement = check xmldata:toJson(description/<Status>);
    json Status = check StatusElement.Status.Status;
    eventHubDescription.Status = Status.toString();
    json PartitionCountElement = check xmldata:toJson(description/<PartitionCount>);
    json PartitionCount = check PartitionCountElement.PartitionCount.PartitionCount;
    eventHubDescription.PartitionCount = check int:fromString(PartitionCount.toString());
    return eventHubDescription;
}

# Convert xml content to updated EventHub record
#
# + xmlContent - xml content
# + return - Return EventHub record or error
isolated function mapXmlToUpdatedEventHubRecord(xml xmlContent) returns EventHub|error {
    xmlns "http://www.w3.org/2005/Atom";
    EventHub eventHub = {};
    json idElementEH = check xmldata:toJson(xmlContent/<id>);
    json idEH = check idElementEH.id.id; 
    eventHub.id = idEH.toString();
    json titleElementEH = check xmldata:toJson(xmlContent/<title>);
    json titleEH = check titleElementEH.title.title; 
    eventHub.title = titleEH.toString();
    json updatedElementEH = check xmldata:toJson(xmlContent/<updated>);
    json updatedEH = check updatedElementEH.updated.updated;
    eventHub.updated = updatedEH.toString();
    json authorElementEH = check xmldata:toJson(xmlContent/<author>/<name>);
    json authorEH = check authorElementEH.name.name;
    eventHub.authorName = authorEH.toString();
    xml content = xmlContent/<content>;
    EventHubDescription eventHubDescription = {};
    eventHubDescription = check mapXmlToEventHubDescriptionRecord(content);
    eventHub.eventHubDescription = eventHubDescription;
    return eventHub;
}

# Convert xml content to RevokePublisher stream
#
# + xmlPayload - xml content
# + return - Return RevokePublisher stream or error
isolated function mapToRevokePublisherStream(xml xmlPayload) returns stream<RevokePublisher>|error {
    xmlns "http://www.w3.org/2005/Atom";
    RevokePublisher[] revokePublishers = [];
    xml entries = xmlPayload/<entry>;
    foreach xml entry in entries {
        RevokePublisher revokePublisher = {};
        revokePublisher = check mapXmlToRevokePublisherRecord(entry);
        revokePublishers.push(revokePublisher);
    }
    return revokePublishers.toStream();
}

# Convert xml content to RevokePublisher record
#
# + xmlContent - xml content
# + return - Return RevokePublisher record or error
isolated function mapXmlToRevokePublisherRecord(xml xmlContent) returns RevokePublisher|error {
    xmlns "http://www.w3.org/2005/Atom";
    RevokePublisher revokePublisher = {};
    json idElementEH = check xmldata:toJson(xmlContent/<id>);
    json idEH = check idElementEH.id.id; 
    revokePublisher.id = idEH.toString();
    json titleElementEH = check xmldata:toJson(xmlContent/<title>);
    json titleEH = check titleElementEH.title.title; 
    revokePublisher.title = titleEH.toString();
    json updatedElementEH = check xmldata:toJson(xmlContent/<updated>);
    json updatedEH = check updatedElementEH.updated.updated;
    revokePublisher.updated = updatedEH.toString();
    xml content = xmlContent/<content>;
    RevokePublisherDescription revokePublisherDescription = {};
    revokePublisherDescription = check mapXmlToRevokePublisherDescriptionRecord(content);
    revokePublisher.revokePublisherDescription = revokePublisherDescription;
    return revokePublisher;
}

# Convert xml content to RevokePublisherDescription record
#
# + xmlContent - xml content
# + return - Return RevokePublisherDescription record or error
isolated function mapXmlToRevokePublisherDescriptionRecord(xml xmlContent) returns RevokePublisherDescription|error {
    xmlns "http://schemas.microsoft.com/netservices/2010/10/servicebus/connect";
    xml description = xmlContent/<RevokedPublisherDescription>;
    RevokePublisherDescription revokePublisherDescription = {};
    json NameElement = check xmldata:toJson(description/<Name>);
    json Name = check NameElement.Name.Name;
    revokePublisherDescription.Name = Name.toString();
    return revokePublisherDescription;
}

# Convert xml content to ConsumerGroup stream
#
# + xmlPayload - xml content
# + return - Return ConsumerGroup stream or error
isolated function mapToConsumerGroupStream(xml xmlPayload) returns stream<ConsumerGroup>|error {
    xmlns "http://www.w3.org/2005/Atom";
    ConsumerGroup[] consumerGroups = [];
    xml entries = xmlPayload/<entry>;
    foreach xml entry in entries {
        ConsumerGroup consumerGroup = {};
        consumerGroup = check mapXmlToConsumerGroupRecord(entry);
        consumerGroups.push(consumerGroup);
    }
    return consumerGroups.toStream();
}

# Convert xml content to ConsumerGroup record
#
# + xmlContent - xml content
# + return - Return ConsumerGroup record or error
isolated function mapXmlToConsumerGroupRecord(xml xmlContent) returns ConsumerGroup|error {
    xmlns "http://www.w3.org/2005/Atom";
    ConsumerGroup consumerGroup = {};
    json idElementEH = check xmldata:toJson(xmlContent/<id>);
    json idEH = check idElementEH.id.id; 
    consumerGroup.id = idEH.toString();
    json titleElementEH = check xmldata:toJson(xmlContent/<title>);
    json titleEH = check titleElementEH.title.title; 
    consumerGroup.title = titleEH.toString();
    json publishedElementEH = check xmldata:toJson(xmlContent/<published>);
    json publishedEH = check publishedElementEH.published.published;
    consumerGroup.published = publishedEH.toString();
    json updatedElementEH = check xmldata:toJson(xmlContent/<updated>);
    json updatedEH = check updatedElementEH.updated.updated;
    consumerGroup.updated = updatedEH.toString();
    return consumerGroup;
}

# Convert xml content to Partition stream
#
# + xmlPayload - xml content
# + return - Return Partition stream or error
isolated function mapToPartitionStream(xml xmlPayload) returns stream<Partition>|error {
    xmlns "http://www.w3.org/2005/Atom";
    Partition[] partitions = [];
    xml entries = xmlPayload/<entry>;
    foreach xml entry in entries {
        Partition partition = {};
        partition = check mapXmlToPartitionRecord(entry);
        partitions.push(partition);
    }
    return partitions.toStream();
}

# Convert xml content to Partition record
#
# + xmlContent - xml content
# + return - Return Partition record or error
isolated function mapXmlToPartitionRecord(xml xmlContent) returns Partition|error {
    xmlns "http://www.w3.org/2005/Atom";
    Partition partition = {};
    json idElementEH = check xmldata:toJson(xmlContent/<id>);
    json idEH = check idElementEH.id.id; 
    partition.id = idEH.toString();
    json titleElementEH = check xmldata:toJson(xmlContent/<title>);
    json titleEH = check titleElementEH.title.title; 
    partition.title = titleEH.toString();
    json publishedElementEH = check xmldata:toJson(xmlContent/<published>);
    json publishedEH = check publishedElementEH.published.published;
    partition.published = publishedEH.toString();
    json updatedElementEH = check xmldata:toJson(xmlContent/<updated>);
    json updatedEH = check updatedElementEH.updated.updated;
    partition.updated = updatedEH.toString();
    xml content = xmlContent/<content>;
    PartitionDescription partitionDescription = {};
    partitionDescription = check mapXmlToPartitionDescriptionRecord(content);
    partition.partitionDescription = partitionDescription;
    return partition;
}

# Convert xml content to PartitionDescription record
#
# + xmlContent - xml content
# + return - Return PartitionDescription record or error
isolated function mapXmlToPartitionDescriptionRecord(xml xmlContent) returns PartitionDescription|error {
    xmlns "http://schemas.microsoft.com/netservices/2010/10/servicebus/connect";
    xml description = xmlContent/<PartitionDescription>;
    PartitionDescription partitionDescription = {};
    json SizeInBytesElement = check xmldata:toJson(description/<SizeInBytes>);
    json SizeInBytes = check SizeInBytesElement.SizeInBytes.SizeInBytes;
    partitionDescription.SizeInBytes = check int:fromString(SizeInBytes.toString());
    json BeginSequenceNumberElement = check xmldata:toJson(description/<BeginSequenceNumber>);
    json BeginSequenceNumber = check BeginSequenceNumberElement.BeginSequenceNumber.BeginSequenceNumber;
    partitionDescription.BeginSequenceNumber = check int:fromString(BeginSequenceNumber.toString());
    json EndSequenceNumberElement = check xmldata:toJson(description/<EndSequenceNumber>);
    json EndSequenceNumber = check EndSequenceNumberElement.EndSequenceNumber.EndSequenceNumber;
    partitionDescription.EndSequenceNumber = check int:fromString(EndSequenceNumber.toString());
    json IncomingBytesPerSecondElement = check xmldata:toJson(description/<IncomingBytesPerSecond>);
    json IncomingBytesPerSecond = check IncomingBytesPerSecondElement.IncomingBytesPerSecond.IncomingBytesPerSecond;
    partitionDescription.IncomingBytesPerSecond = check int:fromString(IncomingBytesPerSecond.toString());
    json OutgoingBytesPerSecondElement = check xmldata:toJson(description/<OutgoingBytesPerSecond>);
    json OutgoingBytesPerSecond = check OutgoingBytesPerSecondElement.OutgoingBytesPerSecond.OutgoingBytesPerSecond;
    partitionDescription.OutgoingBytesPerSecond = check int:fromString(OutgoingBytesPerSecond.toString());
    return partitionDescription;
}
