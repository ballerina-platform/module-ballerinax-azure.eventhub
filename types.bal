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

# The Client endpoint configuration for Azure Event Hubs.
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

# Batch Message Record.
#
# + data - event data 
# + brokerProperties - brokerProperties 
# + userProperties - userProperties 
public type BatchMessage record {|
    anydata data;
    map<json> brokerProperties?;
    map<json> userProperties?;
|};

# Batch Event Record.
#
# + events - set of BatchMessages
public type BatchEvent record {|
    BatchMessage[] events;
|};

# EventHub Description Record.
#
# + MessageRetentionInDays - retention time of the event data
# + Authorization - authorization rules
# + Status - status of the event hub
# + UserMetadata - user metadata
# + PartitionCount - number of subscriptions on the Event Hub
public type EventHubDescription record {|
    int MessageRetentionInDays?;
    string Authorization?;
    string UserMetadata?;
    string Status?;
    int PartitionCount?;
|};

# EventHub Description to Update Record.
#
# + MessageRetentionInDays - event data
public type EventHubDescriptionToUpdate record {|
    int MessageRetentionInDays;
|};

# Consumer group Description Record.
#
# + userMetadata - user metadata
public type ConsumerGroupDescription record {|
    string userMetadata?;
|};

# RevokePublisher Description Record.
#
# + Name - The name of the revoked publisher
public type RevokePublisherDescription record {|
    string Name?;
|};

# Partition Description representation.
#
# + SizeInBytes - Size in bytes 
# + BeginSequenceNumber - Begin sequence number
# + EndSequenceNumber - End sequence number
# + IncomingBytesPerSecond - Incoming bytes per second 
# + OutgoingBytesPerSecond - Outgoing bytes per second
public type PartitionDescription record {
    int SizeInBytes?;
    int BeginSequenceNumber?;
    int EndSequenceNumber?;
    int IncomingBytesPerSecond?;
    int OutgoingBytesPerSecond?;
};

# Even Hub representation.
#
# + id - Identifier of the event hub  
# + title - Name of the event hub 
# + published - Published time  
# + updated - Updated time 
# + authorName - Name of the author(name of the namespace)
# + eventHubDescription - Even Hub description representation 
public type EventHub record {
    string id?;
    string title?;
    string published?;
    string updated?;
    string authorName?;
    EventHubDescription eventHubDescription?;
};

# Consumer Group representation.
#
# + id - Identifier of the consumer group 
# + title - Name of the consumer group
# + published - Published time
# + updated - Updated time
# + consumerGroupDescription - Consumer Group description representation 
public type ConsumerGroup record {
    string id?;
    string title?;
    string published?;
    string updated?;
    ConsumerGroupDescription consumerGroupDescription?;
};

# Revoked Publisher representation.
#
# + id - Identifier of the revoked publisher  
# + title - Name of the revoked publisher
# + updated - Updated time
# + revokePublisherDescription - Revoked Publisher description representation 
public type RevokePublisher record {
    string id?;
    string title?;
    string updated?;
    RevokePublisherDescription revokePublisherDescription?;
};

# Partition representation.
#
# + id - Identifier of the partition 
# + title - Title of the partition
# + published - Published time
# + updated - Updated time
# + partitionDescription - Partition description representation
public type Partition record {
    string id?;
    string title?;
    string published?;
    string updated?;
    PartitionDescription partitionDescription?;
};

# Represents the Eventhub error type.
public type Error distinct error;
