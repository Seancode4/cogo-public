# cogo-public

### App Overview
Cogo allows you to track your habits with friends and family for a more interactive and accountable habit-tracking experience. In the app, users can join a room with friends and track each others progress, building up streaks and group completions. Charts and statistics allow users to analyze their progress over time and motivate continued efforts toward forming positive habits.

### Installation
The app can be downloaded on the iOS App Store. The title of the app is Cogo - Group Habit Tracker. This version of the code cannot be run locally as API keys are removed. A website demonstrating the app capabilities can be found here: https://thecogoapp.carrd.co/

### Files
CoGoApp.swift will automatically log in the user if they recently logged in. If the user is not logged in, it will display the LoginView. Otherwise, it will display BottomTabView and MainScreenView. The MainScreenView displays an overview of all habits the user is working on. Users can get further details of each habit and view live progress of their friends by clicking on the habit. There are also Views for creating and joining rooms and settings.

App models interact with Firebase to retrieve and update data. User.swift retrieves user data from Firebase and resets streaks if limits have not been reached. It manages the viewable rooms by ensuring rooms still exist (were not deleted by another user). Room.swift retrieves the progress of each member in a room and allows users to mark habits as complete, leave a room, get leaderboards and history charts. It also checks streaks and marks if everyone in the room has completed the daily goal. Progress.swift creates objects that store progress information once retrieved from Firebase to minimize unnecessary calls which are updated when Firebase listeners detect a change.

File authorship is described in each file. In general, I did most of the backend and Abigail did most of the front end.
