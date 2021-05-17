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

import ballerina/http;
import ballerina/lang.'xml as xmllib;
import ballerina/regex;
import ballerina/mime;
import ballerina/io;

# Eventhub client implementation.
#
# + config - Client configuration
@display {label: "Azure Event Hubs Client", iconPath: "AzureEventHubLogo.png"}
public client class Client {

    private ClientEndpointConfiguration config;
    private string API_PREFIX = EMPTY_STRING;
    private http:Client clientEndpoint;

    public isolated function init(ClientEndpointConfiguration config) returns error? {
        self.config = config;
        self.API_PREFIX = TIME_OUT + config.timeout.toString() + API_VERSION + config.apiVersion;
        self.clientEndpoint = check new (HTTPS + self.config.resourceUri);
    }

    // Management Client Operations

    # Create a new Eventhub
    #
    # + eventHubPath - event hub path
    # + eventHubDescription - event hub description
    # + return - Return EventHub or Error
    @display {label: "Create Event Hub"}
    remote isolated function createEventHub(@display {label: "Event hub path"} string eventHubPath, 
                                            @display {label: "Event hub description (Optional)"} 
                                            EventHubDescription? eventHubDescription = ()) 
                                            returns @tainted @display {label: "EventHub"} EventHub|error {
        http:Request req = getAuthorizedRequest(self.config);
        xmllib:Element eventHubDes = <xmllib:Element> xml `<EventHubDescription 
            xmlns:i="http://www.w3.org/2001/XMLSchema-instance" 
            xmlns="http://schemas.microsoft.com/netservices/2010/10/servicebus/connect"/>`;
        req.setXmlPayload(getDescriptionProperties(eventHubDescription, eventHubDes));
        string requestPath = FORWARD_SLASH + eventHubPath + self.API_PREFIX;
        http:Response response = <http:Response> check self.clientEndpoint->put(requestPath, req);
        if (response.statusCode == http:STATUS_CREATED) {
            xmlns "http://www.w3.org/2005/Atom";
            xml xmlPayload = check response.getXmlPayload();
            EventHub eventHub = check mapXmlToEventHubRecord(xmlPayload);
            return eventHub;
        }
        return getErrorMessage(response);
    }

    # Get Eventhub description
    #
    # + eventHubPath - event hub path
    # + return - Return EventHub or Error
    @display {label: "Get Event Hub"}
    remote isolated function getEventHub(@display {label: "Event hub path"} string eventHubPath) 
                                         returns @tainted @display {label: "EventHub"} EventHub|error {
        map<string> headerMap = getAuthorizedRequestHeaderMap(self.config);
        string requestPath = FORWARD_SLASH + eventHubPath;
        http:Response response = <http:Response> check self.clientEndpoint->get(requestPath, headerMap);
        if (response.statusCode == http:STATUS_OK) {
            xml xmlPayload = check response.getXmlPayload();
            EventHub eventHub = check mapXmlToEventHubRecord(xmlPayload);
            return eventHub;
        }
        return getErrorMessage(response);
    }

    # Update Eventhub properties
    #
    # + eventHubPath - event hub path
    # + eventHubDescriptionToUpdate - event hub description to update
    # + return - Return EventHub or Error
    @display {label: "Update Event Hub"}
    remote isolated function updateEventHub(@display {label: "Event hub path"} string eventHubPath, 
                                            @display {label: "Event hub description to update"} 
                                            EventHubDescriptionToUpdate eventHubDescriptionToUpdate) 
                                            returns @tainted @display {label: "EventHub"} EventHub|error {
        http:Request req = getAuthorizedRequest(self.config);
        req.addHeader(IF_MATCH, ALL);
        xmllib:Element eventHubDescription = <xmllib:Element> xml `<EventHubDescription 
            xmlns:i="http://www.w3.org/2001/XMLSchema-instance"
            xmlns="http://schemas.microsoft.com/netservices/2010/10/servicebus/connect"/>`;
        req.setXmlPayload(getDescriptionProperties(eventHubDescriptionToUpdate, eventHubDescription));
        string requestPath = FORWARD_SLASH + eventHubPath + self.API_PREFIX;
        http:Response response = <http:Response> check self.clientEndpoint->put(requestPath, req);
        if (response.statusCode == http:STATUS_OK) {
            xmlns "http://www.w3.org/2005/Atom";
            xml xmlPayload = check response.getXmlPayload();
            EventHub eventHub = check mapXmlToUpdatedEventHubRecord(xmlPayload);
            return eventHub;
        } 
        return getErrorMessage(response);
    }

    # Retrieves all metadata associated with all Event Hubs within a specified Service Bus namespace
    #
    # + return - Return stream of event hubs or error
    remote isolated function listEventHubs() returns @tainted @display {label: "EventHub Stream"} 
                                             stream<EventHub>|error {
        map<string> headerMap = getAuthorizedRequestHeaderMap(self.config);
        string requestPath = EVENT_HUBS_PATH;
        http:Response response = <http:Response> check self.clientEndpoint->get(requestPath, headerMap);
        if (response.statusCode == http:STATUS_OK) {
            string textPayload = check response.getTextPayload();
            string cleanedStringXMLObject = regex:replaceAll(textPayload, XML_BASE, BASE);
            xmlns "http://www.w3.org/2005/Atom";
            xml xmlPayload = check 'xml:fromString(cleanedStringXMLObject);
            stream<EventHub> eventHubStream = check mapToEventHubStream(xmlPayload);
            return eventHubStream;       
        } 
        return getErrorMessage(response);
    }

    # Delete an Eventhub
    #
    # + eventHubPath - event hub path
    # + return - Return Error if unsuccessful
    @display {label: "Delete Event Hub"}
    remote isolated function deleteEventHub(@display {label: "Event hub path"} string eventHubPath) 
                                            returns @tainted @display {label: "Result"} error? {
        http:Request req = getAuthorizedRequest(self.config);
        string requestPath = FORWARD_SLASH + eventHubPath;
        http:Response response = <http:Response> check self.clientEndpoint->delete(requestPath, req);
        if (response.statusCode == http:STATUS_OK) {
            return;
        } 
        return getErrorMessage(response);
    }

    # List available partitions
    #
    # + eventHubPath - event hub path
    # + consumerGroupName - consumer group name
    # + return - Return stream of partitions or error
    @display {label: "List Partitions"}
    remote isolated function listPartitions(@display {label: "Event hub path"} string eventHubPath, 
                                            @display {label: "Consumer group name"} string consumerGroupName) 
                                            returns @tainted @display {label: "Partition Stream"} 
                                            stream<Partition>|error {
        map<string> headerMap = getAuthorizedRequestHeaderMap(self.config);
        string requestPath = FORWARD_SLASH + eventHubPath + CONSUMER_GROUP_PATH + consumerGroupName + PARTITIONS_PATH;
        http:Response response = <http:Response> check self.clientEndpoint->get(requestPath, headerMap);
        if (response.statusCode == http:STATUS_OK) {
            string textPayload = check response.getTextPayload();
            string cleanedStringXMLObject = regex:replaceAll(textPayload, XML_BASE, BASE);
            xml xmlPayload = check 'xml:fromString(cleanedStringXMLObject);
            stream<Partition> partitionStream = check mapToPartitionStream(xmlPayload);
            return partitionStream;
        } 
        return getErrorMessage(response);
    }

    # Get partition details
    #
    # + eventHubPath - event hub path
    # + consumerGroupName - consumer group name
    # + partitionId - partitionId 
    # + return - Returns partition details
    @display {label: "Get Partition"}
    remote isolated function getPartition(@display {label: "Event hub path"} string eventHubPath, 
                                          @display {label: "Consumer group name"} string consumerGroupName, 
                                          @display {label: "Partition ID"} int partitionId) 
                                          returns @tainted @display {label: "Partition"} Partition|error {
        map<string> headerMap = getAuthorizedRequestHeaderMap(self.config);
        string requestPath = FORWARD_SLASH + eventHubPath + CONSUMER_GROUP_PATH + consumerGroupName + PARTITION_PATH + 
            partitionId.toString();
        http:Response response = <http:Response> check self.clientEndpoint->get(requestPath, headerMap);
        if (response.statusCode == http:STATUS_OK) {
            xml xmlPayload = check response.getXmlPayload();
            Partition partition = check mapXmlToPartitionRecord(xmlPayload);
            return partition;
        } 
        return getErrorMessage(response);
    }

    # Create consumer group
    #
    # + eventHubPath - event hub path
    # + consumerGroupName - consumer group name
    # + consumerGroupDescription - consumer group description
    # + return - Return Consumer group details or error
    @display {label: "Create Consumer Group"}
    remote isolated function createConsumerGroup(@display {label: "Event hub path"} string eventHubPath, 
                                                 @display {label: "Consumer group name"} string consumerGroupName, 
                                                 @display {label: "Consumer group description (Optional)"} 
                                                 ConsumerGroupDescription? consumerGroupDescription = ()) 
                                                 returns @tainted @display {label: "ConsumerGroup"} 
                                                 ConsumerGroup|error {
        http:Request req = getAuthorizedRequest(self.config);
        xmllib:Element consumerGroupDes = <xmllib:Element> xml `<ConsumerGroupDescription 
            xmlns:i="http://www.w3.org/2001/XMLSchema-instance"
            xmlns="http://schemas.microsoft.com/netservices/2010/10/servicebus/connect"/>`;
        req.setXmlPayload(getDescriptionProperties(consumerGroupDescription, consumerGroupDes));
        string requestPath = FORWARD_SLASH + eventHubPath + CONSUMER_GROUP_PATH + consumerGroupName + self.API_PREFIX;
        http:Response response = <http:Response> check self.clientEndpoint->put(requestPath, req);
        if (response.statusCode == http:STATUS_CREATED) {
            xmlns "http://www.w3.org/2005/Atom";
            xml xmlPayload = check response.getXmlPayload();
            ConsumerGroup consumerGroup = check mapXmlToConsumerGroupRecord(xmlPayload);
            return consumerGroup;
        } 
        return getErrorMessage(response);
    }

    # Get consumer group
    #
    # + eventHubPath - event hub path
    # + consumerGroupName - consumer group name
    # + return - Return Consumer group details or error
    @display {label: "Get Consumer Group"}
    remote isolated function getConsumerGroup(@display {label: "Event hub path"} string eventHubPath, 
                                              @display {label: "Consumer group name"} string consumerGroupName) 
                                              returns @tainted @display {label: "ConsumerGroup"} ConsumerGroup|error {
        map<string> headerMap = getAuthorizedRequestHeaderMap(self.config);
        string requestPath = FORWARD_SLASH + eventHubPath + CONSUMER_GROUP_PATH + consumerGroupName;
        http:Response response = <http:Response> check self.clientEndpoint->get(requestPath, headerMap);
        if (response.statusCode == http:STATUS_OK) {
            xml xmlPayload = check response.getXmlPayload();
            ConsumerGroup consumerGroup = check mapXmlToConsumerGroupRecord(xmlPayload);
            return consumerGroup;
        } 
        return getErrorMessage(response);
    }

    # Delete consumer group
    #
    # + eventHubPath - event hub path
    # + consumerGroupName - consumer group name
    # + return - Return Error if unsuccessful
    @display {label: "Delete Consumer Group"}
    remote isolated function deleteConsumerGroup(@display {label: "Event hub path"} string eventHubPath, 
                                                 @display {label: "Consumer group name"} string consumerGroupName) 
                                                 returns @tainted error? {
        http:Request req = getAuthorizedRequest(self.config);
        string requestPath = FORWARD_SLASH + eventHubPath + CONSUMER_GROUP_PATH + consumerGroupName;
        http:Response response = <http:Response> check self.clientEndpoint->delete(requestPath, req);
        if (response.statusCode == http:STATUS_OK) {
            return;
        } 
        return getErrorMessage(response);
    }

    # List consumer groups
    #
    # + eventHubPath - event hub path
    # + return - Return stream of consumer groups or error
    @display {label: "List Consumer Groups"}
    remote isolated function listConsumerGroups(@display {label: "Event hub path"} string eventHubPath) 
                                                 returns @tainted @display {label: "Consumer Group Stream"} 
                                                 stream<ConsumerGroup>|error {
        map<string> headerMap = getAuthorizedRequestHeaderMap(self.config);
        string requestPath = FORWARD_SLASH + eventHubPath + CONSUMER_GROUPS_PATH;
        http:Response response = <http:Response> check self.clientEndpoint->get(requestPath, headerMap);
        if (response.statusCode == http:STATUS_OK) {
            string textPayload = check response.getTextPayload();
            string cleanedStringXMLObject = regex:replaceAll(textPayload, XML_BASE, BASE);
            xml xmlPayload = check 'xml:fromString(cleanedStringXMLObject);
            stream<ConsumerGroup> consumerGroupStream = check mapToConsumerGroupStream(xmlPayload);
            return consumerGroupStream;
        } 
        return getErrorMessage(response);
    }

    // Publisher Client Operations

    # Send a single event
    #
    # + eventHubPath - event hub path
    # + data - event data
    # + userProperties - user properties
    # + brokerProperties - broker properties
    # + partitionId - partition ID
    # + publisherId - publisher ID 
    # + partitionKey - partition Key
    # + return - @error if remote API is unreachable
    @display {label: "Send an Event"}
    remote isolated function send(@display {label: "Event hub path"} string eventHubPath, 
                                  @display {label: "Event data"} 
                                  string|xml|json|byte[]|mime:Entity[]|stream<byte[], io:Error> data, 
                                  @display {label: "User properties (Optional)"} map<string>? userProperties = (), 
                                  @display {label: "Broker properties (Optional)"} map<anydata>? brokerProperties = (), 
                                  @display {label: "Partition ID (Optional)"} int? partitionId = (), 
                                  @display {label: "Publisher ID (Optional)"} string? publisherId = (), 
                                  @display {label: "Partition Key (Optional)"} string? partitionKey = ()) 
                                  returns @tainted error? {
        http:Request req = getAuthorizedRequest(self.config);
        check req.setContentType(CONTENT_TYPE_SEND);
        if (userProperties is map<string>) {
            foreach var [header, value] in userProperties.entries() {
            req.addHeader(header, value.toString());
        }
        }
        if (partitionKey is string && brokerProperties is map<anydata>) {
            brokerProperties[PARTITION_KEY] = partitionKey;
        } else if (partitionKey is string && brokerProperties is ()) {
            map<anydata> properties = {};
            properties[PARTITION_KEY] = partitionKey;
            json|error props = properties.cloneWithType(json);
            if (props is error) {
                return error Error(BROKER_PROPERTIES_PARSE_ERROR, props);
            } else {
                req.addHeader(BROKER_PROPERTIES, props.toJsonString());
            }
        }
        if (brokerProperties is map<anydata>) {
            json|error props = brokerProperties.cloneWithType(json);
            if (props is error) {
                return error Error(BROKER_PROPERTIES_PARSE_ERROR, props);
            } else {
                req.addHeader(BROKER_PROPERTIES, props.toJsonString());
            }
        }
        req.setPayload(data);
        string postResource = FORWARD_SLASH + eventHubPath;
        if (partitionId is int) {
            //append partition ID
            postResource = postResource + PARTITION_PATH + partitionId.toString();
        }
        if (publisherId is string) {
            //append publisher ID
            postResource = postResource + PUBLISHER_PATH + publisherId;
        }
        postResource = postResource + MESSAGES_PATH;
        string requestPath = postResource + self.API_PREFIX;
        http:Response response = <http:Response> check self.clientEndpoint->post(requestPath, req);
        if (response.statusCode == http:STATUS_CREATED) {
            return;
        }
        return getErrorMessage(response);
    }

    # Send batch of events
    #
    # + eventHubPath - event hub path
    # + batchEvent - batch of events
    # + partitionId - partition ID
    # + publisherId - publisher ID
    # + partitionKey - partition Key
    # + return - Eventhub error if unsuccessful
    @display {label: "Send Batch of Events"}
    remote isolated function sendBatch(@display {label: "Event hub path"} string eventHubPath, 
                                       @display {label: "Batch of events"} BatchEvent batchEvent, 
                                       @display {label: "Partition ID (Optional)"} int? partitionId = (), 
                                       @display {label: "Publisher ID (Optional)"} string? publisherId = (), 
                                       @display {label: "Partition Key (Optional)"} string? partitionKey = ()) 
                                       returns @tainted error? {
        http:Request req = getAuthorizedRequest(self.config);
        check req.setContentType(CONTENT_TYPE_SEND_BATCH);
        if (partitionKey is string) {
            foreach var item in batchEvent.events {
                item.brokerProperties[PARTITION_KEY] = partitionKey;
            }
        }
        req.setJsonPayload(getBatchEventJson(batchEvent));
        string postResource = FORWARD_SLASH + eventHubPath;
        if (partitionId is int) {
            postResource = postResource + PARTITION_PATH + partitionId.toString();
        }
        if (publisherId is string) {
            postResource = postResource + PUBLISHER_PATH + publisherId;
        }
        postResource = postResource + MESSAGES_PATH;
        string requestPath = postResource + self.API_PREFIX;
        http:Response response = <http:Response> check self.clientEndpoint->post(requestPath, req);
        if (response.statusCode != http:STATUS_CREATED) {
            return getErrorMessage(response);
        }
        return;
    }

    # Get details of revoked publishers
    #
    # + eventHubPath - event hub path
    # + return - Return a stream of revoked publishers or Error
    @display {label: "Get Revoked Publishers"}
    remote isolated function getRevokedPublishers(@display {label: "Event hub path"} string eventHubPath) 
                                                  returns @tainted @display {label: "Revoked Publisher Stream"} 
                                                  stream<RevokePublisher>|error {
        map<string> headerMap = getAuthorizedRequestHeaderMap(self.config);
        string requestPath = FORWARD_SLASH + eventHubPath + REVOKED_PUBLISHERS_PATH + self.API_PREFIX;
        http:Response response = <http:Response> check self.clientEndpoint->get(requestPath, headerMap);
        if (response.statusCode == http:STATUS_OK) {
            string textPayload = check response.getTextPayload();
            string cleanedStringXMLObject = regex:replaceAll(textPayload, XML_BASE, BASE);
            xmlns "http://www.w3.org/2005/Atom";
            xml xmlPayload = check 'xml:fromString(cleanedStringXMLObject);
            stream<RevokePublisher> revokePublisherStream = check mapToRevokePublisherStream(xmlPayload);
            return revokePublisherStream;
        } 
        return getErrorMessage(response);
    }

    # Revoke a publisher
    #
    # + eventHubPath - event hub path
    # + publisherName - publisher name 
    # + return - Return revoked publisher details or error
    @display {label: "Revoke a Publisher"}
    remote isolated function revokePublisher(@display {label: "Event hub path"} string eventHubPath, 
                                             @display {label: "Publisher name"} string publisherName) 
                                             returns @tainted @display {label: "RevokedPublisher"} 
                                             RevokePublisher|error {
        http:Request req = getAuthorizedRequest(self.config);
        RevokePublisherDescription revokePublisherDescription = {
            Name: publisherName
        };
        xmllib:Element revPubDes = <xmllib:Element> xml `<RevokedPublisherDescription 
            xmlns:i="http://www.w3.org/2001/XMLSchema-instance" 
            xmlns="http://schemas.microsoft.com/netservices/2010/10/servicebus/connect"/>`;
        req.setXmlPayload(getDescriptionProperties(revokePublisherDescription, revPubDes));
        string requestPath = FORWARD_SLASH + eventHubPath + REVOKED_PUBLISHER_PATH + publisherName + 
            TIME_OUT_AND_API_VERSION;
        http:Response response = <http:Response> check self.clientEndpoint->put(requestPath, req);
        if (response.statusCode == http:STATUS_CREATED) {
            xml xmlPayload = check response.getXmlPayload();
            RevokePublisher revokePublisher = check mapXmlToRevokePublisherRecord(xmlPayload);
            return revokePublisher;
        } 
        return getErrorMessage(response);
    }

    # Resume a publisher
    #
    # + eventHubPath - event hub path
    # + publisherName - publisher name 
    # + return - Return publisher details or error
    @display {label: "Resume a Publisher"}
    remote isolated function resumePublisher(@display {label: "Event hub path"} string eventHubPath, 
                                             @display {label: "Publisher name"} string publisherName) 
                                             returns @tainted error? {
        http:Request req = getAuthorizedRequest(self.config);
        string requestPath = FORWARD_SLASH + eventHubPath + REVOKED_PUBLISHER_PATH + publisherName;
        http:Response response = <http:Response> check self.clientEndpoint->delete(requestPath, req);
        if (response.statusCode == http:STATUS_OK) {
            return;
        }
        return getErrorMessage(response);
    }
}
