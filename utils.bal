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

import ballerina/crypto;
import ballerina/url;
import ballerina/http;
import ballerina/time;
import ballerina/jballerina.java;
import ballerina/regex;

# Get request with common headers
#
# + config - Client endpoint configuration
# + return - Return a http request with authorization header
isolated function getAuthorizedRequest(ClientEndpointConfiguration config) returns http:Request {
    http:Request req = new;
    req.addHeader(AUTHORIZATION_HEADER, getSASToken(config));
    if (config?.enableRetry == false) {
        // disable automatic retry
        req.addHeader(RETRY_POLICY, NO_RETRY);
    }
    return req;
}

isolated function getAuthorizedRequestHeaderMap(ClientEndpointConfiguration config) returns map<string> {
    map<string> headerMap = {
            "Authorization": getSASToken(config)
    };
    if (config?.enableRetry == false) {
        // disable automatic retry
        headerMap = {
            "Authorization": getSASToken(config),
            "x-ms-retrypolicy": NO_RETRY
        };
    }
    return headerMap;
}

# Generate the SAS token
#
# + config - Client endpoint configuration
# + return - Return SAS token
isolated function getSASToken(ClientEndpointConfiguration config) returns string {
    time:Utc time = time:utcNow();
    [int, decimal][epochSeconds, lastSecondFraction] = time;
    int week = 60 * 60 * 24 * 7;
    int expiry = epochSeconds + week;
    string stringToSign = checkpanic url:encode(config.resourceUri, UTF8_URL_ENCODING) + "\n" + 
        expiry.toString();
    byte[] output = checkpanic crypto:hmacSha256(stringToSign.toBytes(), config.sasKey.toBytes());
    string signature = output.toBase64();
    string sasToken = "SharedAccessSignature sr="
        + checkpanic url:encode(config.resourceUri, UTF8_URL_ENCODING)
        + "&sig=" + checkpanic url:encode(signature, UTF8_URL_ENCODING)
        + "&se=" + expiry.toString() + "&skn=" + config.sasKeyName;
    return sasToken;
}

# Get the error message from the response.
#
# + response - Received response.
# + return - Returns module error with payload and response code.
isolated function getErrorMessage(http:Response response) returns @tainted error {
    return error Error("Invalid response from EventHub API. statuscode: " + response.statusCode.toString() + 
        ", payload: " + check response.getTextPayload(), status = response.statusCode);
}

# Create a random UUID removing the unnecessary hyphens which will interrupt querying opearations.
# 
# + return - A string UUID without hyphens
public function createRandomUUIDWithoutHyphens() returns string {
    string? stringUUID = java:toString(createRandomUUID());
    if (stringUUID is string) {
        stringUUID = regex:replaceAll(stringUUID, "-", "");
        return stringUUID;
    } else {
        return "";
    }
}

function createRandomUUID() returns handle = @java:Method {
    name: "randomUUID",
    'class: "java.util.UUID"
} external;
