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
# + sasKeyName - Shared access service key name
# + sasKey - Shared access service key 
# + resourceUri - Resource URI. This is in the format {eventhubname}.servicebus.windows.net
# + timeout - Operation timeout
# + enableRetry - Make it false to disable automatic retry on send operations when transient errors occur
@display {label: "Connection Config"}
public type ClientEndpointConfiguration record {|
    @display {label: "SAS Key Name"}
    string sasKeyName;
    @display {label: "SAS Key"}
    string sasKey;
    @display {label: "Resource Uri"}
    string resourceUri;
    @display {label: "Timeout"}
    int timeout?;
    @display {label: "Enable Retry"}
    boolean enableRetry?;
|};

# Represents a single event in a batch of events.
#
# + data - Event data
# + brokerProperties - Map of broker properties 
# + userProperties - Map of custom properties 
@display {label: "Event"}
public type Event record {|
    @display {label: "Event Data"}
    anydata data;
    @display {label: "Broker Properties"}
    map<json> brokerProperties?;
    @display {label: "User Properties"}
    map<json> userProperties?;
|};

# Represents a batch of events.
#
# + events - Array of Event records
@display {label: "Batch Event"}
public type BatchEvent record {|
    @display {label: "Events"}
    Event[] events;
|};

# Represents the metadata description of an Event Hub.
#
# + MessageRetentionInDays - Number of days to retain the events for this Event Hub
# + Authorization - Authorization rules
# + Status - Current status of the Event Hub
# + UserMetadata - User metadata
# + PartitionCount - Current number of shards on the Event Hub
@display {label: "Event Hub Description"}
public type EventHubDescription record {|
    @display {label: "Message Retention (Days)"}
    int MessageRetentionInDays?;
    @display {label: "Authorization"}
    string Authorization?;
    @display {label: "User Metadata"}
    string UserMetadata?;
    @display {label: "Status"}
    string Status?;
    @display {label: "Partition Count"}
    int PartitionCount?;
|};

# Represents the metadata description to update in an Event Hub.
#
# + MessageRetentionInDays - Number of days to retain the events for this Event Hub
@display {label: "Event Hub Description To Update"}
public type EventHubDescriptionToUpdate record {|
    @display {label: "Message Retention (Days)"}
    int MessageRetentionInDays;
|};

# Represents a description of the consumer group.
#
# + userMetadata - User metadata
@display {label: "Consumer Group Description"}
public type ConsumerGroupDescription record {|
    @display {label: "User Metadata"}
    string userMetadata?;
|};

# Represents a description of the revoked publisher.
#
# + Name - The name of the revoked publisher
@display {label: "Revoke Publisher Description"}
public type RevokePublisherDescription record {|
    @display {label: "Revoke Publisher Name"}
    string Name?;
|};

# Represents the metadata and approximate runtime information for a logical partition of an Event Hub.
#
# + SizeInBytes - Size in bytes 
# + BeginSequenceNumber - Begin sequence number
# + EndSequenceNumber - End sequence number
# + IncomingBytesPerSecond - Incoming bytes per second 
# + OutgoingBytesPerSecond - Outgoing bytes per second
@display {label: "Partition Description"}
public type PartitionDescription record {
    @display {label: "Size In Bytes"}
    int SizeInBytes?;
    @display {label: "Begin Seq Num"}
    int BeginSequenceNumber?;
    @display {label: "End Seq Num"}
    int EndSequenceNumber?;
    @display {label: "Incoming Bytes (Per Sec)"}
    int IncomingBytesPerSecond?;
    @display {label: "Outgoing Bytes (Per Sec)"}
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
@display {label: "Event Hub"}
public type EventHub record {
    @display {label: "Id"}
    string id?;
    @display {label: "Title"}
    string title?;
    @display {label: "Published"}
    string published?;
    @display {label: "Updated"}
    string updated?;
    @display {label: "Author Name"}
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
@display {label: "Consumer Group"}
public type ConsumerGroup record {
    @display {label: "Id"}
    string id?;
    @display {label: "Title"}
    string title?;
    @display {label: "Published"}
    string published?;
    @display {label: "Updated"}
    string updated?;
    ConsumerGroupDescription consumerGroupDescription?;
};

# Revoked Publisher representation.
#
# + id - Identifier of the revoked publisher  
# + title - Name of the revoked publisher
# + updated - Updated time
# + revokePublisherDescription - Revoked Publisher description representation 
@display {label: "Revoked Publisher"}
public type RevokePublisher record {
    @display {label: "Id"}
    string id?;
    @display {label: "Title"}
    string title?;
    @display {label: "Updated"}
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
@display {label: "Partition"}
public type Partition record {
    @display {label: "Id"}
    string id?;
    @display {label: "Title"}
    string title?;
    @display {label: "Published"}
    string published?;
    @display {label: "Updated"}
    string updated?;
    PartitionDescription partitionDescription?;
};

# Represents the Eventhub error type.
public type Error distinct error;
