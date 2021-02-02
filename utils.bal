// Copyright (c) 2020, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
// import ballerina/io;
// import ballerina/log;
import ballerina/time;

# Get request with common headers
#
# + return - Return a http request with authorization header
isolated function getAuthorizedRequest(ClientEndpointConfiguration config) returns http:Request {
    http:Request req = new;
    req.addHeader(AUTHORIZATION_HEADER, getSASToken(config));
    if (!config.enableRetry) {
        // disable automatic retry
        req.addHeader(RETRY_POLICY, NO_RETRY);
    }
    return req;
}

# Generate the SAS token
#
# + return - Return SAS token
isolated function getSASToken(ClientEndpointConfiguration config) returns string {
    time:Time time = time:currentTime();
    int currentTimeMills = time.time / 1000;
    int week = 60 * 60 * 24 * 7;
    int expiry = currentTimeMills + week;
    string stringToSign = <string>encoding:encodeUriComponent(config.resourceUri, UTF8_URL_ENCODING) + "\n" + 
        expiry.toString();
    string signature = crypto:hmacSha256(stringToSign.toBytes(), config.sasKey.toBytes()).toBase64();
    string sasToken = "SharedAccessSignature sr="
        + <string>encoding:encodeUriComponent(config.resourceUri, UTF8_URL_ENCODING)
        + "&sig=" + <string>encoding:encodeUriComponent(signature, UTF8_URL_ENCODING)
        + "&se=" + expiry.toString() + "&skn=" + config.sasKeyName;
    // log:print(io:sprintf("SAS token: [%s]", sasToken));
    return sasToken;
}

# Get the error message from the response.
#
# + response - Received response.
# + return - Returns module error with payload and response code.
isolated function getErrorMessage(http:Response response) returns @tainted error {
    return Error("Invalid response from EventHub API. statuscode: " + response.statusCode.toString() + ", payload: " + 
        response.getTextPayload().toString(), status = response.statusCode);
}
