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
import ballerina/mime;
import ballerina/lang.'xml as xmllib;
import ballerina/regex;
import ballerina/io;

# Eventhub publisher client implementation.
#
# + config - Client configuration
@display {label: "Azure Event Hubs Publisher Client", iconPath: "AzureEventHubLogo.png"}
public client class PublisherClient {

    private ClientEndpointConfiguration config;
    private string API_PREFIX = EMPTY_STRING;
    private http:Client clientEndpoint;

    public isolated function init(ClientEndpointConfiguration config) returns error? {
        self.config = config;
        self.API_PREFIX = TIME_OUT + config.timeout.toString() + API_VERSION + config.apiVersion;
        self.clientEndpoint = check new (HTTPS + self.config.resourceUri);
    }

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
                         @display {label: "User properties"} map<string> userProperties = {}, 
                         @display {label: "Broker properties"} map<anydata> brokerProperties = {}, 
                         @display {label: "Partition ID"} int partitionId = -1, 
                         @display {label: "Publisher ID"} string publisherId = "", 
                         @display {label: "Partition Key"} string partitionKey = "") 
                         returns @tainted error? {
        http:Request req = getAuthorizedRequest(self.config);
        check req.setContentType(CONTENT_TYPE_SEND);
        foreach var [header, value] in userProperties.entries() {
            req.addHeader(header, value.toString());
        }
        if (partitionKey != "") {
            brokerProperties[PARTITION_KEY] = partitionKey;
        }
        if (brokerProperties.length() > 0) {
            json|error props = brokerProperties.cloneWithType(json);
            if (props is error) {
                return error Error(BROKER_PROPERTIES_PARSE_ERROR, props);
            } else {
                req.addHeader(BROKER_PROPERTIES, props.toJsonString());
            }
        }
        req.setPayload(data);
        string postResource = FORWARD_SLASH + eventHubPath;
        if (partitionId > -1) {
            //append partition ID
            postResource = postResource + PARTITION_PATH + partitionId.toString();
        }
        if (publisherId != "") {
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
                              @display {label: "Partition ID"} int partitionId = -1, 
                              @display {label: "Publisher ID"} string publisherId = "", 
                              @display {label: "Partition Key"} string partitionKey = "") 
                              returns @tainted error? {
        http:Request req = getAuthorizedRequest(self.config);
        check req.setContentType(CONTENT_TYPE_SEND_BATCH);
        if (partitionKey != "") {
            foreach var item in batchEvent.events {
                item.brokerProperties[PARTITION_KEY] = partitionKey;
            }
        }
        req.setJsonPayload(getBatchEventJson(batchEvent));
        string postResource = FORWARD_SLASH + eventHubPath;
        if (partitionId > -1) {
            postResource = postResource + PARTITION_PATH + partitionId.toString();
        }
        if (publisherId != "") {
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
    # + return - Return revoke publisher or Error
    @display {label: "Get Revoked Publishers"}
    remote isolated function getRevokedPublishers(@display {label: "Event hub path"} string eventHubPath) 
                                         returns @tainted @display {label: "Result"} xml|error {
        map<string> headerMap = getAuthorizedRequestHeaderMap(self.config);
        string requestPath = FORWARD_SLASH + eventHubPath + REVOKED_PUBLISHERS_PATH + self.API_PREFIX;
        http:Response response = <http:Response> check self.clientEndpoint->get(requestPath, headerMap);
        if (response.statusCode == http:STATUS_OK) {
            string textPayload = check response.getTextPayload();
            string cleanedStringXMLObject = regex:replaceAll(textPayload, XML_BASE, BASE);
            xml xmlPayload = check 'xml:fromString(cleanedStringXMLObject);
            return xmlPayload;
        } 
        return getErrorMessage(response);
    }

    # Revoke a publisher
    #
    # + eventHubPath - event hub path
    # + publisherName - publisher name 
    # + return - Return revoke publisher details or error
    @display {label: "Revoke a Publisher"}
    remote isolated function revokePublisher(@display {label: "Event hub path"} string eventHubPath, 
                                    @display {label: "Publisher name"} string publisherName) 
                                    returns @tainted @display {label: "Result"} xml|error {
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
            return xmlPayload;
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
