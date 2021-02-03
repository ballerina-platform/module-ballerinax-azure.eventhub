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
import ballerina/stringutils;

# Eventhub management client implementation.
#
# + config - Client configuration
public client class ManagementClient {

    private ClientEndpointConfiguration config;
    private string API_PREFIX = EMPTY_STRING;
    private http:Client clientEndpoint;

    public function init(ClientEndpointConfiguration config) {
        self.config = config;
        self.API_PREFIX = TIME_OUT + config.timeout.toString() + API_VERSION + config.apiVersion;
        self.clientEndpoint = new (HTTPS + self.config.resourceUri);
    }

    # Create a new Eventhub
    #
    # + eventHubPath - event hub path
    # + eventHubDescription - event hub description
    # + return - Return XML or Error
    remote function createEventHub(string eventHubPath, EventHubDescription eventHubDescription = {}) 
            returns @tainted xml|error {
        http:Request req = getAuthorizedRequest(self.config);
        xmllib:Element eventHubDes = <xmllib:Element> xml `<EventHubDescription 
            xmlns:i="http://www.w3.org/2001/XMLSchema-instance" 
            xmlns="http://schemas.microsoft.com/netservices/2010/10/servicebus/connect"/>`;
        req.setXmlPayload(getDescriptionProperties(eventHubDescription, eventHubDes));
        string requestPath = FORWARD_SLASH + eventHubPath + self.API_PREFIX;
        http:Response response = <http:Response> check self.clientEndpoint->put(requestPath, req);
        if (response.statusCode == SUCCESS) {
            xml xmlPayload = check response.getXmlPayload();
            return xmlPayload;
        }
        return getErrorMessage(response);
    }

    # Get Eventhub description
    #
    # + eventHubPath - event hub path
    # + return - Return XML or Error
    remote function getEventHub(string eventHubPath) returns @tainted xml|error {
        http:Request req = getAuthorizedRequest(self.config);
        string requestPath = FORWARD_SLASH + eventHubPath;
        http:Response response = <http:Response> check self.clientEndpoint->get(requestPath, req);
        if (response.statusCode == OK) {
            xml xmlPayload = check response.getXmlPayload();
            return xmlPayload;
        }
        return getErrorMessage(response);
    }

    # Update Eventhub properties
    #
    # + eventHubPath - event hub path
    # + eventHubDescriptionToUpdate - event hub description to update
    # + return - Return XML or Error
    remote function updateEventHub(string eventHubPath, EventHubDescriptionToUpdate eventHubDescriptionToUpdate) 
            returns @tainted xml|error {
        http:Request req = getAuthorizedRequest(self.config);
        req.addHeader(IF_MATCH, ALL);
        xmllib:Element eventHubDescription = <xmllib:Element> xml `<EventHubDescription 
            xmlns:i="http://www.w3.org/2001/XMLSchema-instance"
            xmlns="http://schemas.microsoft.com/netservices/2010/10/servicebus/connect"/>`;
        req.setXmlPayload(getDescriptionProperties(eventHubDescriptionToUpdate, eventHubDescription));
        string requestPath = FORWARD_SLASH + eventHubPath + self.API_PREFIX;
        http:Response response = <http:Response> check self.clientEndpoint->put(requestPath, req);
        if (response.statusCode == OK) {
            xml xmlPayload = check response.getXmlPayload();
            return xmlPayload;
        } 
        return getErrorMessage(response);
    }

    # Retrieves all metadata associated with all Event Hubs within a specified Service Bus namespace
    #
    # + return - Return list of event hubs or error
    remote function listEventHubs() returns @tainted xml|error {
        http:Request req = getAuthorizedRequest(self.config);
        string requestPath = EVENT_HUBS_PATH;
        http:Response response = <http:Response> check self.clientEndpoint->get(requestPath, req);
        if (response.statusCode == OK) {
            string textPayload = check response.getTextPayload();
            string cleanedStringXMLObject = stringutils:replaceAll(textPayload, XML_BASE, BASE);
            xml xmlPayload = check 'xml:fromString(cleanedStringXMLObject);
            return xmlPayload;       
        } 
        return getErrorMessage(response);
    }

    # Delete an Eventhub
    #
    # + eventHubPath - event hub path
    # + return - Return Error if unsuccessful
    remote function deleteEventHub(string eventHubPath) returns @tainted error? {
        http:Request req = getAuthorizedRequest(self.config);
        string requestPath = FORWARD_SLASH + eventHubPath;
        http:Response response = <http:Response> check self.clientEndpoint->delete(requestPath, req);
        if (response.statusCode == OK) {
            return;
        } 
        return getErrorMessage(response);
    }

    # List available partitions
    #
    # + eventHubPath - event hub path
    # + consumerGroupName - consumer group name
    # + return - Return partition list or error
    remote function listPartitions(string eventHubPath, string consumerGroupName) returns @tainted xml|error {
        http:Request req = getAuthorizedRequest(self.config);
        string requestPath = FORWARD_SLASH + eventHubPath + CONSUMER_GROUP_PATH + consumerGroupName + PARTITIONS_PATH;
        http:Response response = <http:Response> check self.clientEndpoint->get(requestPath, req);
        if (response.statusCode == OK) {
            string textPayload = check response.getTextPayload();
            string cleanedStringXMLObject = stringutils:replaceAll(textPayload, XML_BASE, BASE);
            xml xmlPayload = check 'xml:fromString(cleanedStringXMLObject);
            return xmlPayload;
        } 
        return getErrorMessage(response);
    }

    # Get partition details
    #
    # + eventHubPath - event hub path
    # + consumerGroupName - consumer group name
    # + partitionId - partitionId 
    # + return - Returns partition details
    remote function getPartition(string eventHubPath, string consumerGroupName, int partitionId) 
            returns @tainted xml|error {
        http:Request req = getAuthorizedRequest(self.config);
        string requestPath = FORWARD_SLASH + eventHubPath + CONSUMER_GROUP_PATH + consumerGroupName + PARTITION_PATH + 
            partitionId.toString();
        http:Response response = <http:Response> check self.clientEndpoint->get(requestPath, req);
        if (response.statusCode == OK) {
            xml xmlPayload = check response.getXmlPayload();
            return xmlPayload;
        } 
        return getErrorMessage(response);
    }

    # Create consumer group
    #
    # + eventHubPath - event hub path
    # + consumerGroupName - consumer group name
    # + consumerGroupDescription - consumer group description
    # + return - Return Consumer group details or error
    remote function createConsumerGroup(string eventHubPath, string consumerGroupName, 
            ConsumerGroupDescription consumerGroupDescription = {}) returns @tainted xml|error {
        http:Request req = getAuthorizedRequest(self.config);
        xmllib:Element consumerGroupDes = <xmllib:Element> xml `<ConsumerGroupDescription 
            xmlns:i="http://www.w3.org/2001/XMLSchema-instance"
            xmlns="http://schemas.microsoft.com/netservices/2010/10/servicebus/connect"/>`;
        req.setXmlPayload(getDescriptionProperties(consumerGroupDescription, consumerGroupDes));
        string requestPath = FORWARD_SLASH + eventHubPath + CONSUMER_GROUP_PATH + consumerGroupName + self.API_PREFIX;
        http:Response response = <http:Response> check self.clientEndpoint->put(requestPath, req);
        if (response.statusCode == SUCCESS) {
            xml xmlPayload = check response.getXmlPayload();
            return xmlPayload;
        } 
        return getErrorMessage(response);
    }

    # Get consumer group
    #
    # + eventHubPath - event hub path
    # + consumerGroupName - consumer group name
    # + return - Return Consumer group details or error
    remote function getConsumerGroup(string eventHubPath, string consumerGroupName) returns @tainted xml|error {
        http:Request req = getAuthorizedRequest(self.config);
        string requestPath = FORWARD_SLASH + eventHubPath + CONSUMER_GROUP_PATH + consumerGroupName;
        http:Response response = <http:Response> check self.clientEndpoint->get(requestPath, req);
        if (response.statusCode == OK) {
            xml xmlPayload = check response.getXmlPayload();
            return xmlPayload;
        } 
        return getErrorMessage(response);
    }

    # Delete consumer group
    #
    # + eventHubPath - event hub path
    # + consumerGroupName - consumer group name
    # + return - Return Error if unsuccessful
    remote function deleteConsumerGroup(string eventHubPath, string consumerGroupName) returns @tainted error? {
        http:Request req = getAuthorizedRequest(self.config);
        string requestPath = FORWARD_SLASH + eventHubPath + CONSUMER_GROUP_PATH + consumerGroupName;
        http:Response response = <http:Response> check self.clientEndpoint->delete(requestPath, req);
        if (response.statusCode == OK) {
            return;
        } 
        return getErrorMessage(response);
    }

    # List consumer groups
    #
    # + eventHubPath - event hub path
    # + return - Return list of consumer group or error
    remote function listConsumerGroups(string eventHubPath) returns @tainted xml|error {
        http:Request req = getAuthorizedRequest(self.config);
        string requestPath = FORWARD_SLASH + eventHubPath + CONSUMER_GROUPS_PATH;
        http:Response response = <http:Response> check self.clientEndpoint->get(requestPath, req);
        if (response.statusCode == OK) {
            string textPayload = check response.getTextPayload();
            string cleanedStringXMLObject = stringutils:replaceAll(textPayload, XML_BASE, BASE);
            xml xmlPayload = check 'xml:fromString(cleanedStringXMLObject);
            return xmlPayload;
        } 
        return getErrorMessage(response);
    }
}
