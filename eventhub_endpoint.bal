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

import ballerina/http;
import ballerina/io;
import ballerina/mime;
import ballerina/lang.'xml as xmllib;

# Eventhub client implementation.
#
# + config - Client configuration
public client class Client {

    private ClientEndpointConfiguration config;
    private string API_PREFIX = "";
    private http:Client clientEndpoint;

    public function init(ClientEndpointConfiguration config) returns error? {
        self.config = config;
        self.API_PREFIX = "?timeout=" + config.timeout.toString() + "&api-version=" + config.apiVersion;
        self.clientEndpoint = new ("https://" + self.config.resourceUri);
    }

    # Send a single event
    #
    # + userProperties - user properties
    # + eventHubPath - event hub path
    # + publisherId - publisher ID 
    # + data - event data
    # + brokerProperties - broker properties
    # + partitionId - partition ID
    # + return - @error if remote API is unreachable
    remote function send(string eventHubPath, string|xml|json|byte[]|io:ReadableByteChannel|mime:Entity[] data, map<string> userProperties = {},
        map<anydata> brokerProperties = {}, int partitionId = -1, string publisherId = "") returns @tainted error? {
        http:Request req = getAuthorizedRequest(self.config);
        req.setHeader("Content-Type", "application/atom+xml;type=entry;charset=utf-8");
        foreach var [header, value] in userProperties.entries() {
            req.addHeader(header, value.toString());
        }
        if (brokerProperties.length() > 0) {
            json|error props = brokerProperties.cloneWithType(json);
            if (props is error) {
                return Error("unbale to parse broker properties ", props);
            } else {
                req.addHeader("BrokerProperties", props.toJsonString());
            }
        }
        req.setPayload(data);
        string postResource = "/" + eventHubPath;
        if (partitionId > -1) {
            //append partition ID
            postResource = postResource + "/partitions/" + partitionId.toString();
        }
        if (publisherId != "") {
            //append publisher ID
            postResource = postResource + "/publisher/" + publisherId;
        }
        postResource = postResource + "/messages";
        var response = self.clientEndpoint->post(postResource + self.API_PREFIX, req);
        if (response is http:Response) {
            int statusCode = response.statusCode;
            if (statusCode == 201) {
                return;
            }
            return Error("invalid response from EventHub API. status code: " + response.statusCode.toString()
                + ", payload: " + response.getTextPayload().toString());
        } else {
            return Error("error invoking EventHub API ", <error>response);
        }
    }

    # Send batch of events
    #
    # + batchEvent - batch of events
    # + eventHubPath - event hub path
    # + partitionId - partition ID
    # + publisherId - publisher ID
    # + return - Eventhub error if unsuccessful
    remote function sendBatch(string eventHubPath, BatchEvent batchEvent, int partitionId = -1, string publisherId = "") returns @tainted error? {
        http:Request req = getAuthorizedRequest(self.config);
        req.setJsonPayload(getBatchEventJson(batchEvent));
        req.setHeader("content-type", "application/vnd.microsoft.servicebus.json");
        string postResource = "/" + eventHubPath;
        if (partitionId > -1) {
            postResource = postResource + "/partitions/" + partitionId.toString();
        }

        if (publisherId != "") {
            postResource = postResource + "/publishers/" + publisherId;
        }
        postResource = postResource + "/messages";
        var response = self.clientEndpoint->post(postResource, req);
        if (response is http:Response) {
            int statusCode = response.statusCode;
            if (statusCode != 201) {
                return Error("invalid response from EventHub API. status code: " + response.statusCode.toString()
                    + ", payload: " + response.getTextPayload().toString());
            }
        } else {
            return Error("error invoking EventHub API ",  <error>response);
        }
    }

    # Create a new Eventhub
    #
    # + eventHubPath - event hub path
    # + eventHubDescription - event hub description
    # + return - Return XML or Error
    remote function createEventHub(string eventHubPath, EventHubDescription eventHubDescription = {}) returns @tainted xml|error {
        http:Request req = getAuthorizedRequest(self.config);
        xmllib:Element eventHubDes = <xmllib:Element> xml `<EventHubDescription xmlns:i="http://www.w3.org/2001/XMLSchema-instance"
                  xmlns="http://schemas.microsoft.com/netservices/2010/10/servicebus/connect"/>`;
        req.setXmlPayload(getDescriptionProperties(eventHubDescription, eventHubDes));
        var response = self.clientEndpoint->put("/" + eventHubPath + self.API_PREFIX, req);
        if (response is http:Response) {
            var xmlPayload = response.getXmlPayload();
            if (xmlPayload is xml) {
                return xmlPayload;
            }
            return Error("invalid response from EventHub API. status code: " + response.statusCode.toString()
                + ", payload: " + response.getTextPayload().toString());
        } else {
            return Error("error invoking EventHub API ", <error>response);
        }
    }

    # Get Eventhub description
    #
    # + eventHubPath - event hub path
    # + return - Return XML or Error
    remote function getEventHub(string eventHubPath) returns @tainted xml|error {
        http:Request req = getAuthorizedRequest(self.config);
        var response = self.clientEndpoint->get("/" + eventHubPath, req);
        if (response is http:Response) {
            var xmlPayload = response.getXmlPayload();
            if (xmlPayload is xml) {
                return xmlPayload;
            }
            return Error("invalid response from EventHub API. status code: " + response.statusCode.toString()
                + ", payload: " + response.getTextPayload().toString());
        } else {
            return Error("error invoking EventHub API ", <error>response);
        }
    }

    # Update Eventhub properties
    #
    # + eventHubPath - event hub path
    # + eventHubDescriptionToUpdate - event hub description to update
    # + return - Return XML or Error
    remote function updateEventHub(string eventHubPath, EventHubDescriptionToUpdate eventHubDescriptionToUpdate) returns @tainted xml|error {
        http:Request req = getAuthorizedRequest(self.config);
        req.addHeader("If-Match", "*");
        xmllib:Element eventHubDescription = <xmllib:Element> xml `<EventHubDescription xmlns:i="http://www.w3.org/2001/XMLSchema-instance"
                  xmlns="http://schemas.microsoft.com/netservices/2010/10/servicebus/connect"/>`;
        req.setXmlPayload(getDescriptionProperties(eventHubDescriptionToUpdate, eventHubDescription));
        var response = self.clientEndpoint->put("/" + eventHubPath + self.API_PREFIX, req);
        if (response is http:Response) {
            var xmlPayload = response.getXmlPayload();
            if (xmlPayload is xml) {
                return xmlPayload;
            }
            return Error("invalid response from EventHub API. status code: " + response.statusCode.toString()
                + ", payload: " + response.getTextPayload().toString());
        } else {
            return Error("error invoking EventHub API ", <error>response);
        }
    }

    # Retrieves all metadata associated with all Event Hubs within a specified Service Bus namespace
    #
    # + return - Return list of event hubs or error
    remote function listEventHubs() returns @tainted xml|error {
        http:Request req = getAuthorizedRequest(self.config);
        var response = self.clientEndpoint->get("/$Resources/EventHubs", req);
        if (response is http:Response) {
            var xmlPayload = response.getXmlPayload();
            if (xmlPayload is xml) {
                return xmlPayload;
            }
            return Error("invalid response from EventHub API. status code: " + response.statusCode.toString()
                + ", payload: " + response.getTextPayload().toString());
        } else {
            return Error("error invoking EventHub API ", <error>response);
        }
    }

    # Delete an Eventhub
    #
    # + eventHubPath - event hub path
    # + return - Return Error if unsuccessful
    remote function deleteEventHub(string eventHubPath) returns @tainted error? {
        http:Request req = getAuthorizedRequest(self.config);
        var response = self.clientEndpoint->delete("/" + eventHubPath, req);
        if (response is http:Response) {
            int statusCode = response.statusCode;
            if (statusCode == 200) {
                return;
            }
            return Error("invalid response from EventHub API. status code: " + response.statusCode.toString()
               + ", payload: " + response.getTextPayload().toString());
        } else {
            return Error("error invoking EventHub API ", <error>response);
        }
    }

    # Get details of revoked publisher
    #
    # + eventHubPath - event hub path
    # + return - Return revoke publisher or Error
    remote function getRevokedPublishers(string eventHubPath) returns @tainted xml|error {
        http:Request req = getAuthorizedRequest(self.config);
        var response = self.clientEndpoint->get("/" + eventHubPath + "/revokedpublishers", req);
        if (response is http:Response) {
            var xmlPayload = response.getXmlPayload();
            if (xmlPayload is xml) {
                return xmlPayload;
            }
            return Error("invalid response while getting revoked publishers: status code: " + response.statusCode.toString()
                + ", payload: " + response.getTextPayload().toString());
        } else {
            return Error("error invoking EventHub API ", <error>response);
        }
    }

    # Revoke a publisher
    #
    # + eventHubPath - event hub path
    # + publisherName - publisher name 
    # + return - Return revoke publisher details or error
    remote function revokePublisher(string eventHubPath, string publisherName) returns @tainted xml|error {
        http:Request req = getAuthorizedRequest(self.config);
        var response = self.clientEndpoint->put("/" + eventHubPath + "/revokedpublishers/" + publisherName, req);
        if (response is http:Response) {
            var xmlPayload = response.getXmlPayload();
            if (xmlPayload is xml) {
                return xmlPayload;
            }
            return Error("invalid response while revoking publisher: " + publisherName
                + ". " + response.statusCode.toString());
        } else {
            return Error("error invoking EventHub API ", <error>response);
        }
    }

    # Resume a publisher
    #
    # + eventHubPath - event hub path
    # + publisherName - publisher name 
    # + return - Return publisher details or error
    remote function resumePublisher(string eventHubPath, string publisherName) returns @tainted error? {
        http:Request req = getAuthorizedRequest(self.config);
        var response = self.clientEndpoint->delete("/" + eventHubPath + "/revokedpublishers/" + publisherName, req);
        if (response is http:Response) {
            int statusCode = response.statusCode;
            if (statusCode == 200) {
                return;
            }
            return Error("invalid response from EventHub API " + response.statusCode.toString());
        } else {
            return Error("error invoking EventHub API ", <error>response);
        }
    }

    # Lit available partitions
    #
    # + eventHubPath - event hub path
    # + consumerGroupName - consumer group name
    # + return - Return partition list or error
    remote function listPartitions(string eventHubPath, string consumerGroupName) returns @tainted xml|error {
        http:Request req = getAuthorizedRequest(self.config);
        var response = self.clientEndpoint->get("/" + eventHubPath + "/consumergroups/" + consumerGroupName + "/partitions", req);
        if (response is http:Response) {
            var xmlPayload = response.getXmlPayload();
            if (xmlPayload is xml) {
                return xmlPayload;
            }
            return Error("invalid response from EventHub API " + response.statusCode.toString());
        } else {
            return Error("error invoking EventHub API ", <error>response);
        }
    }

    # Get partition details
    #
    # + eventHubPath - event hub path
    # + consumerGroupName - consumer group name
    # + partitionId - partitionId 
    # + return - Returns partition details
    remote function getPartition(string eventHubPath, string consumerGroupName, int partitionId) returns @tainted xml|error {
        http:Request req = getAuthorizedRequest(self.config);
        var response = self.clientEndpoint->get("/" + eventHubPath + "/consumergroups/" + consumerGroupName + "/partitions/" + partitionId.toString(), req);
        if (response is http:Response) {
            var xmlPayload = response.getXmlPayload();
            if (xmlPayload is xml) {
                return xmlPayload;
            }
            return Error("invalid response from EventHub API " + response.statusCode.toString());
        } else {
            return Error("error invoking EventHub API ", <error>response);
        }
    }

    # Create consumer group
    #
    # + eventHubPath - event hub path
    # + consumerGroupName - consumer group name
    # + consumerGroupDescription - consumer group description
    # + return - Return Consumer group details or error
    remote function createConsumerGroup(string eventHubPath, string consumerGroupName, ConsumerGroupDescription consumerGroupDescription = {}) returns @tainted xml|error {
        http:Request req = getAuthorizedRequest(self.config);
        xmllib:Element consumerGroupDes = <xmllib:Element> xml `<ConsumerGroupDescription xmlns:i="http://www.w3.org/2001/XMLSchema-instance"
                  xmlns="http://schemas.microsoft.com/netservices/2010/10/servicebus/connect"/>`;
        req.setXmlPayload(getDescriptionProperties(consumerGroupDescription, consumerGroupDes));
        var response = self.clientEndpoint->put("/" + eventHubPath + "/consumergroups/" + consumerGroupName + self.API_PREFIX, req);
        if (response is http:Response) {
            var xmlPayload = response.getXmlPayload();
            if (xmlPayload is xml) {
                return xmlPayload;
            }
            return Error("invalid response from EventHub API " + response.statusCode.toString());
        } else {
            return Error("error invoking EventHub API ", <error>response);
        }
    }

    # Get consumer group
    #
    # + eventHubPath - event hub path
    # + consumerGroupName - consumer group name
    # + return - Return Consumer group details or error
    remote function getConsumerGroup(string eventHubPath, string consumerGroupName) returns @tainted xml|error {
        http:Request req = getAuthorizedRequest(self.config);
        var response = self.clientEndpoint->get("/" + eventHubPath + "/consumergroups/" + consumerGroupName, req);
        if (response is http:Response) {
            var xmlPayload = response.getXmlPayload();
            if (xmlPayload is xml) {
                return xmlPayload;
            }
            return Error("invalid response from EventHub API " + response.statusCode.toString());
        } else {
            return Error("error invoking EventHub API ", <error>response);
        }
    }

    # Delete consumer group
    #
    # + eventHubPath - event hub path
    # + consumerGroupName - consumer group name
    # + return - Return Error if unsuccessful
    remote function deleteConsumerGroup(string eventHubPath, string consumerGroupName) returns @tainted error? {
        http:Request req = getAuthorizedRequest(self.config);
        var response = self.clientEndpoint->delete("/" + eventHubPath + "/consumergroups/" + consumerGroupName, req);
        if (response is http:Response) {
            int statusCode = response.statusCode;
            if (statusCode == 200) {
                return;
            }
            return Error("invalid response from EventHub API. status code: " + response.statusCode.toString()
               + ", payload: " + response.getTextPayload().toString());
        } else {
            return Error("error invoking EventHub API ", <error>response);
        }
    }

    # List consumer groups
    #
    # + eventHubPath - event hub path
    # + return - Return list of consumer group or error
    remote function listConsumerGroups(string eventHubPath) returns @tainted xml|error {
        http:Request req = getAuthorizedRequest(self.config);
        var response = self.clientEndpoint->get("/" + eventHubPath + "/consumergroups", req);
        if (response is http:Response) {
            int statusCode = response.statusCode;
            var xmlPayload = response.getXmlPayload();
            if (xmlPayload is xml) {
                return xmlPayload;
            }
            return Error("invalid response from EventHub API " + response.statusCode.toString());
        } else {
            return Error("error invoking EventHub API ", <error>response);
        }
    }
}
