# ERD and Firestore mapping

![ERD](ERD.png)

Firestore is a document database, so each entity below is a collection (or a
subcollection) and each foreign key is a stored document id / uid.

```mermaid
erDiagram
    USERS ||--o{ LISTINGS : "sells (sellerId)"
    USERS ||--o{ CONVERSATIONS : "is seller (sellerId)"
    USERS ||--o{ CONVERSATIONS : "is buyer (buyerId)"
    LISTINGS ||--o{ CONVERSATIONS : "is discussed in (listingId)"
    CONVERSATIONS ||--o{ MESSAGES : "contains"
    USERS ||--o{ MESSAGES : "sends (senderId)"
    USERS ||--o{ REPORTS : "files (reporterId)"
    USERS ||--o{ REPORTS : "is reported (reportedUid)"
    CONVERSATIONS ||--o{ REPORTS : "context (conversationId)"

    USERS {
        string uid PK "doc id = Firebase Auth uid"
        string name
        string email
        string year
        string hub
        timestamp createdAt
    }
    LISTINGS {
        string id PK "auto id"
        string sellerId FK "users.uid"
        string sellerName
        string title
        string category
        string hub
        int price "RWF"
        int photoCount
        string status "active | sold"
        string soldToName "set when sold"
        timestamp soldAt "set when sold"
        timestamp createdAt
    }
    CONVERSATIONS {
        string id PK "listingId_buyerId"
        string[] participantIds "[sellerId, buyerId]"
        string listingId FK "listings.id"
        string listingTitle
        string sellerId FK "users.uid"
        string sellerName
        string buyerId FK "users.uid"
        string buyerName
        string lastMessage
        timestamp lastMessageAt
        string meetup "optional"
        string[] unreadBy "uids with unread messages"
    }
    MESSAGES {
        string id PK "auto id, subcollection conversations/{id}/messages"
        string senderId FK "users.uid"
        string text
        timestamp createdAt
    }
    REPORTS {
        string id PK "auto id"
        string reporterId FK "users.uid"
        string reportedUid FK "users.uid"
        string conversationId FK "conversations.id"
        string reason
        timestamp createdAt
    }
```

## Intentional denormalisation
`sellerName`, `buyerName` and `listingTitle` are copied into `conversations`, and
`sellerName` into `listings`, so the inbox and the home feed render from a single
query without one extra read per row. They are written once at creation time.

## Indexes
No composite indexes are required: every query uses a single filter
(`sellerId ==`, `status ==`, `participantIds array-contains`) and results are sorted on the
device. `messages` are ordered by the single field `createdAt`, which is indexed automatically.
