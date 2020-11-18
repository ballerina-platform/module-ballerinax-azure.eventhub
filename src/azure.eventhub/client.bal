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

import ballerina/crypto;
import ballerina/encoding;
import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerina/mime;
import ballerina/time;

# Eventhub client implementation
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
    # + publisherId - publisher ID 
    # + data - event data
    # + brokerProperties - broker properties
    # + partitionId - partition ID
    # + return - @error if remote API is unreachable
    public remote function send(string|xml|json|byte[]|io:ReadableByteChannel|mime:Entity[] data, map<string> userProperties = {},
        map<anydata> brokerProperties = {}, int partitionId = -1, string publisherId = "") returns @tainted error? {
        http:Request req = self.getAuthorizedRequest();
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
        string postResource = "";
        if (partitionId > -1) {
            //append partition ID
            postResource = "/partitions/" + partitionId.toString();
        }
        if (publisherId != "") {
            //append publisher ID
            postResource = "/publisher/" + publisherId;
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

    # Get request with common headers
    #
    # + return - Return a http request with authorization header
    private isolated function getAuthorizedRequest() returns http:Request {
        http:Request req = new;
        req.addHeader("Authorization", self.getSASToken());
        if (!self.config.enableRetry) {
            // disable automatic retry
            req.addHeader("x-ms-retrypolicy", "NoRetry");
        }
        return req;
    }

    # Send batch of events
    #
    # + batchEvent - batch of events
    # + partitionId - partition ID
    # + publisherId - publisher ID
    # + return - Eventhub error if unsuccessful
    public remote function sendBatch(BatchEvent batchEvent, int partitionId = -1, string publisherId = "") returns @tainted error? {
        http:Request req = self.getAuthorizedRequest();
        req.setJsonPayload(self.getBatchEventJson(batchEvent));
        req.setHeader("content-type", "application/vnd.microsoft.servicebus.json");
        string postResource = "/messages";
        if (partitionId > -1) {
            postResource = "/partitions/" + partitionId.toString() + postResource;
        }

        if (publisherId != "") {
            postResource = "/publishers/" + publisherId + postResource;
        }
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

    # Get Eventhub deatils
    #
    # + return - Return XML or Error
    public remote function getEventHub() returns @tainted xml|error {
        http:Request req = self.getAuthorizedRequest();
        var response = self.clientEndpoint->get("/", req);
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

    # Get details of revoked publisher
    #
    # + return - Return revoke publisher or Error
    public remote function getRevokedPublishers() returns @tainted xml|error {
        http:Request req = self.getAuthorizedRequest();
        var response = self.clientEndpoint->get("/revokedpublishers", req);
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
    # + publisherName - publisher name 
    # + return - Return revoke publisher details or error
    public remote function revokePublisher(string publisherName) returns @tainted xml|error {
        http:Request req = self.getAuthorizedRequest();
        var response = self.clientEndpoint->put("/revokedpublishers/" + publisherName, req);
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
    # + publisherName - publisher name 
    # + return - Return publisher details or error
    public remote function resumePublisher(string publisherName) returns @tainted xml|error {
        http:Request req = self.getAuthorizedRequest();
        var response = self.clientEndpoint->delete("/revokedpublishers/" + publisherName, req);
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

    # Lit available partitions
    #
    # + consumerGroupName - consumer group name
    # + return - Return partition list or error
    public remote function listPartitions(string consumerGroupName) returns @tainted xml|error {
        http:Request req = self.getAuthorizedRequest();
        var response = self.clientEndpoint->get("/consumergroups/" + consumerGroupName + "/partitions", req);
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
    # + consumerGroupName - consumer group name
    # + partitionId - partitionId 
    # + return - Returns partition details
    public remote function getPartition(string consumerGroupName, int partitionId) returns @tainted xml|error {
        http:Request req = self.getAuthorizedRequest();
        var response = self.clientEndpoint->get("/consumergroups/" + consumerGroupName + "/partitions/" + partitionId.toString(), req);
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
    # + consumerGroupName - consumer group name Parameter Description
    # + return - Return Consumer group details or error
    public remote function getConsumerGroups(string consumerGroupName) returns @tainted xml|error {
        http:Request req = self.getAuthorizedRequest();
        var response = self.clientEndpoint->get("/consumergroups/" + consumerGroupName, req);
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

    # List consumer groups
    #
    # + return - Return list of consumer group or error
    public remote function listConsumerGroups() returns @tainted xml|error {
        http:Request req = self.getAuthorizedRequest();
        var response = self.clientEndpoint->get("/consumergroups", req);
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

    # Convert batch event to json
    #
    # + batchEvent - batch event 
    # + return - Return eventhub formatted json
    private isolated function getBatchEventJson(BatchEvent batchEvent) returns json {
        json[] message = [];
        foreach var item in batchEvent.events {
            json data = checkpanic item.data.cloneWithType(json);
            json j = {
                Body: data
            };
            if (!(item["userProperties"] is ())) {
                json userProperties = {UserProperties:checkpanic item["userProperties"].cloneWithType(json)};
                j = checkpanic j.mergeJson(userProperties);
            }
            if (!(item["brokerProperties"] is ())) {
                json brokerProperties = {BrokerProperties:checkpanic item["brokerProperties"].cloneWithType(json)};
                j = checkpanic j.mergeJson(brokerProperties);
            }
            message.push(j);
        }
        return message;
    }

    # Generate the SAS token
    #
    # + return - Return SAS token
    private isolated function getSASToken() returns string {
        time:Time time = time:currentTime();
        int currentTimeMills = time.time / 1000;
        int week = 60 * 60 * 24 * 7;
        int expiry = currentTimeMills + week;
        string stringToSign = <string>encoding:encodeUriComponent(self.config.resourceUri, "UTF-8") + "\n" + expiry.toString();
        string signature = crypto:hmacSha256(stringToSign.toBytes(), self.config.sasKey.toBytes()).toBase64();
        string sasToken = "SharedAccessSignature sr="
            + <string>encoding:encodeUriComponent(self.config.resourceUri, "UTF-8")
            + "&sig=" + <string>encoding:encodeUriComponent(signature, "UTF-8")
            + "&se=" + expiry.toString() + "&skn=" + self.config.sasKeyName;
        log:printDebug(io:sprintf("SAS token: [%s]", sasToken));
        return sasToken;
    }
};

# The Client endpoint configuration for Redis databases.
#
# + sasKeyName - shared access service key name
# + sasKey - shared access service key 
# + resourceUri - resource URI
# + timeout - timeout
# + apiVersion - apiVersion 
# + enableRetry - enableRetry
public type ClientEndpointConfiguration record {|
    string sasKeyName;
    string sasKey;
    string resourceUri;
    int timeout = 60;
    string apiVersion = "2014-01";
    boolean enableRetry = true;
|};

# Batch Message Record
#
# + data - event data 
# + brokerProperties - brokerProperties 
# + userProperties - userProperties 
public type BatchMessage record {|
    anydata data;
    map<json> brokerProperties?;
    map<json> userProperties?;
|};

# Batch Event Record
#
# + events - set of BatchMessages
public type BatchEvent record {|
    BatchMessage[] events;
|};

# Represents the Eventhub error type.
public type Error distinct error;
