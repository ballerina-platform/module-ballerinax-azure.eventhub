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

# Client for Azure Event Hub connector.
#
# + config - Client configuration
@display {label: "Azure Event Hub", iconPath: "logo.png"}
public client class Client {

    private ClientEndpointConfiguration config;
    private string API_PREFIX = EMPTY_STRING;
    private http:Client clientEndpoint;

    public isolated function init(ClientEndpointConfiguration config) returns error? {
        self.config = config;
        if (config?.timeout == ()) {
            self.API_PREFIX = API_VERSION_ONLY;
        } else {
            self.API_PREFIX = TIME_OUT + config?.timeout.toString() + API_VERSION;
        }
        self.clientEndpoint = check new (HTTPS + self.config.resourceUri);
    }

    // Management Client Operations

    # Create a new Event Hub.
    #
    # + eventHubPath - Event Hub path (Event Hub name)
    # + eventHubDescription - EventHubDescription record with properties to set (Optional)
    # + return - EventHub record on success, else returns an error
    @display {label: "Create Event Hub"}
    remote isolated function createEventHub(@display {label: "Event Hub Path"} string eventHubPath, 
                                            @display {label: "Event Hub Description"} 
                                            EventHubDescription? eventHubDescription = ()) 
                                            returns @tainted @display {label: "Event Hub"} EventHub|error {
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

    # Get all metadata associated with the specified Event Hub.
    #
    # + eventHubPath - Event Hub path (Event Hub name)
    # + return - EventHub record on success, else returns an error
    @display {label: "Get Event Hub"}
    remote isolated function getEventHub(@display {label: "Event Hub Path"} string eventHubPath) 
                                         returns @tainted @display {label: "Event Hub"} EventHub|error {
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

    # Update Event Hub properties.
    #
    # + eventHubPath - Event Hub path (Event Hub name)
    # + eventHubDescriptionToUpdate - EventHubDescriptionToUpdate record with properties to update
    # + return - EventHub record on success, else returns an error
    @display {label: "Update Event Hub"}
    remote isolated function updateEventHub(@display {label: "Event Hub Path"} string eventHubPath, 
                                            @display {label: "Update Description"} 
                                            EventHubDescriptionToUpdate eventHubDescriptionToUpdate) 
                                            returns @tainted @display {label: "Event Hub"} EventHub|error {
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

    # Retrieves all metadata associated with all Event Hubs within a specified Service Bus namespace.
    #
    # + return - Stream of EventHub records on success, else returns an error
    @display {label: "List Event Hubs"}
    remote isolated function listEventHubs() returns @tainted @display {label: "Stream of Event Hubs"} 
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

    # Delete an Event Hub.
    #
    # + eventHubPath - Event Hub path (Event Hub name)
    # + return - Nil on success, else returns an error
    @display {label: "Delete Event Hub"}
    remote isolated function deleteEventHub(@display {label: "Event Hub Path"} string eventHubPath) 
                                            returns @tainted error? {
        http:Request req = getAuthorizedRequest(self.config);
        string requestPath = FORWARD_SLASH + eventHubPath;
        http:Response response = <http:Response> check self.clientEndpoint->delete(requestPath, req);
        if (response.statusCode == http:STATUS_OK) {
            return;
        } 
        return getErrorMessage(response);
    }

    # List available partitions on an Event Hub.
    #
    # + eventHubPath - Event Hub path (Event Hub name)
    # + consumerGroupName - Consumer group name
    # + return - Stream of Partition records on success, else returns an error
    @display {label: "List Partitions"}
    remote isolated function listPartitions(@display {label: "Event Hub Path"} string eventHubPath, 
                                            @display {label: "Consumer Group Name"} string consumerGroupName) 
                                            returns @tainted @display {label: "Stream of Partitions"} 
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

    # Get specified partition details on an Event Hub.
    #
    # + eventHubPath - Event Hub path (Event Hub name)
    # + consumerGroupName - Consumer group name
    # + partitionId - Partition ID 
    # + return - Partition record on success, else returns an error
    @display {label: "Get Partition"}
    remote isolated function getPartition(@display {label: "Event Hub Path"} string eventHubPath, 
                                          @display {label: "Consumer Group Name"} string consumerGroupName, 
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

    # Creates a new consumer group. 
    #
    # + eventHubPath - Event Hub name
    # + consumerGroupName - Consumer group name
    # + consumerGroupDescription - ConsumerGroupDescription record with properties to set (Optional)
    # + return - ConsumerGroup record on success, else returns an error
    @display {label: "Create Consumer Group"}
    remote isolated function createConsumerGroup(@display {label: "Event Hub Path"} string eventHubPath, 
                                                 @display {label: "Consumer Group Name"} string consumerGroupName, 
                                                 @display {label: "Consumer Group Description"} 
                                                 ConsumerGroupDescription? consumerGroupDescription = ()) 
                                                 returns @tainted @display {label: "Consumer Group"} 
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

    # Retrieves all metadata associated with the specified consumer group. 
    #
    # + eventHubPath - Event Hub path (Event Hub name)
    # + consumerGroupName - Consumer group name
    # + return - ConsumerGroup record on success, else returns an error
    @display {label: "Get Consumer Group"}
    remote isolated function getConsumerGroup(@display {label: "Event Hub Path"} string eventHubPath, 
                                              @display {label: "Consumer Group Name"} string consumerGroupName) 
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

    # Delete consumer group.
    #
    # + eventHubPath - Event Hub path (Event Hub name)
    # + consumerGroupName - Consumer group name
    # + return - Nil on success, else returns an error
    @display {label: "Delete Consumer Group"}
    remote isolated function deleteConsumerGroup(@display {label: "Event Hub Path"} string eventHubPath, 
                                                 @display {label: "Consumer Group Name"} string consumerGroupName) 
                                                 returns @tainted error? {
        http:Request req = getAuthorizedRequest(self.config);
        string requestPath = FORWARD_SLASH + eventHubPath + CONSUMER_GROUP_PATH + consumerGroupName;
        http:Response response = <http:Response> check self.clientEndpoint->delete(requestPath, req);
        if (response.statusCode == http:STATUS_OK) {
            return;
        } 
        return getErrorMessage(response);
    }

    # Retrieves all consumer groups associated with the specified Event Hub. 
    #
    # + eventHubPath - Event Hub path (Event Hub name)
    # + return - Stream of ConsumerGroup records on success, else returns an error
    @display {label: "List Consumer Groups"}
    remote isolated function listConsumerGroups(@display {label: "Event Hub Path"} string eventHubPath) 
                                                 returns @tainted @display {label: "Stream of ConsumerGroups"} 
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

    # Send a single event to an Event Hub.
    #
    # + eventHubPath - Event Hub path (Event Hub name)
    # + data - Event data in json format
    # + userProperties - Map of custom properties (Optional)
    # + brokerProperties - Map of broker properties (Optional)
    # + partitionId - Partition ID (Optional)
    # + publisherId - Publisher ID (Optional)
    # + partitionKey - Partition Key (Optional)
    # + return - Nil on success, else returns an error if remote API is unreachable
    @display {label: "Send an Event"}
    remote isolated function send(@display {label: "Event Hub Path"} string eventHubPath, 
                                  @display {label: "Event Data"} json data, 
                                  @display {label: "User Properties"} map<json>? userProperties = (), 
                                  @display {label: "Broker Properties"} map<json>? brokerProperties = (), 
                                  @display {label: "Partition ID"} int? partitionId = (), 
                                  @display {label: "Publisher ID"} string? publisherId = (), 
                                  @display {label: "Partition Key"} string? partitionKey = ()) 
                                  returns @tainted error? {
        http:Request req = getAuthorizedRequest(self.config);
        check req.setContentType(CONTENT_TYPE_SEND);
        if (userProperties is map<json>) {
            foreach var [header, value] in userProperties.entries() {
            req.addHeader(header, value.toJsonString());
        }
        }
        if (partitionKey is string && brokerProperties is map<json>) {
            brokerProperties[PARTITION_KEY] = partitionKey;
        } else if (partitionKey is string && brokerProperties is ()) {
            map<json> properties = {};
            properties[PARTITION_KEY] = partitionKey;
            json|error props = properties.cloneWithType(json);
            if (props is error) {
                return error Error(BROKER_PROPERTIES_PARSE_ERROR, props);
            } else {
                req.addHeader(BROKER_PROPERTIES, props.toJsonString());
            }
        }
        if (brokerProperties is map<json>) {
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

    # Send batch of events to an Event Hub.
    #
    # + eventHubPath - Event Hub path (Event Hub name)
    # + batchEvent - BatchEvent record that represents batch of events
    # + partitionId - Partition ID (Optional)
    # + publisherId - Publisher ID (Optional)
    # + partitionKey - Partition Key (Optional)
    # + return - Nil on success, else returns an error
    @display {label: "Send Batch of Events"}
    remote isolated function sendBatch(@display {label: "Event Hub Path"} string eventHubPath, 
                                       @display {label: "Batch of Events"} BatchEvent batchEvent, 
                                       @display {label: "Partition ID"} int? partitionId = (), 
                                       @display {label: "Publisher ID"} string? publisherId = (), 
                                       @display {label: "Partition Key"} string? partitionKey = ()) 
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

    # Retrieves all revoked publishers within the specified Event Hub. 
    #
    # + eventHubPath - Event Hub path (Event Hub name)
    # + return - Stream of RevokePublisher records on success, else returns an error
    @display {label: "Get Revoked Publishers"}
    remote isolated function getRevokedPublishers(@display {label: "Event Hub Path"} string eventHubPath) 
                                                  returns @tainted @display {label: "Stream of RevokePublishers"} 
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

    # Revokes a publisher. A revoked publisher will encounter errors when sending an event to the specified Event Hub.
    #
    # + eventHubPath - Event Hub path (Event Hub name)
    # + publisherName - Publisher name 
    # + return - RevokedPublisher record on success, else returns an error
    @display {label: "Revoke a Publisher"}
    remote isolated function revokePublisher(@display {label: "Event Hub Path"} string eventHubPath, 
                                             @display {label: "Publisher Name"} string publisherName) 
                                             returns @tainted @display {label: "Revoked Publisher"} 
                                             RevokePublisher|error {
        http:Request req = getAuthorizedRequest(self.config);
        RevokePublisherDescription revokePublisherDescription = {
            Name: publisherName
        };
        xmllib:Element revPubDes = <xmllib:Element> xml `<RevokedPublisherDescription 
            xmlns:i="http://www.w3.org/2001/XMLSchema-instance" 
            xmlns="http://schemas.microsoft.com/netservices/2010/10/servicebus/connect"/>`;
        req.setXmlPayload(getDescriptionProperties(revokePublisherDescription, revPubDes));
        string requestPath = "";
        if (self.config?.timeout == ()) {
            requestPath = FORWARD_SLASH + eventHubPath + REVOKED_PUBLISHER_PATH + publisherName + 
                API_VERSION_ONLY_REVOKE_PUBLISHER;
        } else {
            requestPath = FORWARD_SLASH + eventHubPath + REVOKED_PUBLISHER_PATH + publisherName + 
                TIME_OUT + self.config?.timeout.toString() + API_VERSION_REVOKE_PUBLISHER;
        }
        http:Response response = <http:Response> check self.clientEndpoint->put(requestPath, req);
        if (response.statusCode == http:STATUS_CREATED) {
            xml xmlPayload = check response.getXmlPayload();
            RevokePublisher revokePublisher = check mapXmlToRevokePublisherRecord(xmlPayload);
            return revokePublisher;
        } 
        return getErrorMessage(response);
    }

    # Restores a revoked publisher. This operation enables the publisher to resume sending events to 
    # the specified Event Hub.
    #
    # + eventHubPath - Event Hub path (Event Hub name)
    # + publisherName - Publisher name 
    # + return - Nil on success, else returns an error
    @display {label: "Resume a Publisher"}
    remote isolated function resumePublisher(@display {label: "Event Hub Path"} string eventHubPath, 
                                             @display {label: "Publisher Name"} string publisherName) 
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
