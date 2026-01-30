# Demo Setup Instructions

## Required Appwrite Storage Bucket

Before running the demo, you need to create a storage bucket in Appwrite:

1. Go to your Appwrite Console
2. Navigate to Storage
3. Create a new bucket with ID: `child-photos`
4. Set permissions to allow read access for "Any" user:
   - Add Permission: Read - Role: Any

This bucket will store the geotagged photos taken during baseline assessments.

## New Demo Features

### 1. Location Capture
- Field workers must click "Get Location" button to capture GPS coordinates
- Location is automatically captured when taking photos
- Coordinates are stored in the visits table

### 2. Geotagged Photos
- Field workers must take a geotagged photo of the child before submitting baseline
- Photo is uploaded to Appwrite storage and URL stored in database
- Photo appears on the child's profile screen

### 3. Enhanced Child Profile
- Cleaner, card-based UI showing assessment progress
- Child's photo displayed instead of just initials
- Progress tracking for all assessment phases

## Demo Flow

1. Add new child → fills basic info
2. Baseline assessment → capture location + photo + answer questions
3. Submit baseline → child synced to database
4. View child profile → see photo and progress
5. Start counselling → checklist-based counselling system