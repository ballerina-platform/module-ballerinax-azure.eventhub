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

# EventHub Description Record
#
# + messageRetentionInDays - retention time of the event data
# + authorization - authorization rules
# + status - status of the event hub
# + userMetadata - user metadata
# + partitionCount - number of subscriptions on the Event Hub
public type EventHubDescription record {|
    int messageRetentionInDays?;
    string authorization?;
    string userMetadata?;
    string status?;
    int partitionCount?;
|};

# EventHub Description Record
#
# + messageRetentionInDays - event data
public type EventHubDescriptionToUpdate record {|
    int messageRetentionInDays;
|};

# Consumer group Description Record
#
# + userMetadata - user metadata
public type ConsumerGroupDescription record {|
    string userMetadata?;
|};

# Represents the Eventhub error type.
public type Error distinct error;
