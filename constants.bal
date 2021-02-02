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

// Request Headers
const string AUTHORIZATION_HEADER = "Authorization";
const string RETRY_POLICY = "x-ms-retrypolicy";
const string BROKER_PROPERTIES = "BrokerProperties";
const string IF_MATCH = "If-Match";

// Request Headers Values
const string CONTENT_TYPE_SEND = "application/atom+xml;type=entry;charset=utf-8";
const string CONTENT_TYPE_SEND_BATCH = "application/vnd.microsoft.servicebus.json";
const string ALL = "*";
const string NO_RETRY = "NoRetry";

// Encoding types
const string UTF8_URL_ENCODING = "UTF-8";

// Response Status Codes
const int OK = 200;
const int SUCCESS = 201;

// URL paths
const string PARTITIONS_PATH = "/partitions";
const string PARTITION_PATH = "/partitions/";
const string PUBLISHER_PATH = "/publishers/";
const string MESSAGES_PATH = "/messages";
const string EVENT_HUBS_PATH = "/$Resources/EventHubs";
const string REVOKED_PUBLISHERS_PATH = "/revokedpublishers";
const string REVOKED_PUBLISHER_PATH = "/revokedpublishers/";
const string CONSUMER_GROUPS_PATH = "/consumergroups";
const string CONSUMER_GROUP_PATH = "/consumergroups/";

// URL suffixes and prefixes
const string TIME_OUT = "?timeout=";
const string API_VERSION = "&api-version=";
const string HTTPS = "https://";
const string TIME_OUT_AND_API_VERSION = "?timeout=60&api-version=2014-05";

// Error messages
const string BROKER_PROPERTIES_PARSE_ERROR = "Unable to parse broker properties ";

// String Constants
const string EMPTY_STRING = "";
const string FORWARD_SLASH = "/";
const string XML_BASE = "xml:base";
const string BASE = "base";
