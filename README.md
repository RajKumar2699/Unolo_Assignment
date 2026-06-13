# iOS Engineer Assignment

A simple iOS photo gallery app built with UIKit, MVVM, Core Data, and SDWebImage.

## Features

- Displays a list of photos from an API.
- Supports local caching with Core Data.
- Lets users edit photo titles.
- Lets users delete photos.
- Uses pagination for smooth scrolling.
- Shows loading, empty, and error states.

## Tech Stack

- Swift
- UIKit
- Core Data
- MVVM architecture
- SDWebImage

## Project Structure

- `PhotoListViewController` – main list screen.
- `PhotoListViewModel` – handles state and pagination.
- `PhotoRepository` – manages API and Core Data operations.
- `PhotoCell` – custom table view cell.
- `PhotoDetailViewController` – photo detail screen.

## Requirements

- Xcode 15 or later
- iOS 16 or later
- Swift 6 compatible project

## Setup

1. Clone the repository.
2. Open the `.xcodeproj` or `.xcworkspace` file in Xcode.
3. Install dependencies if needed.
4. Build and run the app on a simulator or device.

## Usage

1. Launch the app.
2. Wait for photos to load.
3. Scroll to load more photos.
4. Tap a photo to view details.
5. Edit the title or delete the photo.

## Notes

- Images are loaded asynchronously using SDWebImage.
- Pagination is used to improve scrolling performance.
- Core Data is used for offline persistence.

## GitHub Submission

If you are reviewing this project, the main branch contains the latest source code and assignment implementation.

## License

This project is created for assignment/demo purposes.
