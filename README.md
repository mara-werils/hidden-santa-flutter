# hidden_santa

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---
# Assignment 3 Report: UI Design and Layout Implementation

## Course: Mobile App Development  
**Week:** 3  
**Students Name:** Azamat Nagumanov, Marlen Amanbayev, Dias Omar  
**Group:** SE-2328  
**GitHub Repository:** [https://github.com/mara-werils/hidden-santa-flutter/](https://github.com/mara-werils/hidden-santa-flutter/)

---

## Objective
The goal of this assignment was to design and implement the main (home) screen of a Flutter application using layout and widget systems. The UI had to be responsive, scrollable, and adapt to various screen sizes and orientations.

---

## Implementation Details

### Main Screen Layout
Implemented using Flutter layout widgets such as:
- **Column**
- **Row**
- **Container**
- **Padding**
- **SizedBox**
- **Expanded**

Includes:
- Header
- Main content
- Bottom section

UI designed to be visually complete and user-friendly.

---

### Scrollable Content
- Used **ListView** / **GridView** for scrollable content.
- Smooth scrolling ensured via built-in Flutter scrolling behavior.
- Tested with content that exceeds the screen height.

---

### Responsive Layout
- Used **MediaQuery** to dynamically adapt widget sizes.
- **Flexible** and **Expanded** used within Rows/Columns.
- Layout adapts to:
  - Small phones
  - Medium devices
  - Large tablets

---

### Orientation Support
- **In portrait mode**: Vertical stacking of sections.
- **In landscape mode**: Horizontal layout rearrangement for better space usage.

---

### UI Polish
- Colors follow a consistent theme (primary and secondary shades).
- Text styled with custom **TextStyle** (fontSize, weight, color).
- Icons/images used to enhance user experience.
- Widgets organized into modular files with comments for maintainability.

---

## Screenshots
![image](https://github.com/user-attachments/assets/2224436a-8ac7-4feb-a7f3-2a8742fa2fdf)
![image](https://github.com/user-attachments/assets/802a3743-4eb5-4f62-a357-90c44a37a701)
![image](https://github.com/user-attachments/assets/44cc4de0-18c3-48ad-9c64-ac9a830df2bd)
![image](https://github.com/user-attachments/assets/b5e5cc13-8bcb-4ad6-a842-123a471cd853)

Bigger size device
![image](https://github.com/user-attachments/assets/8a0f91fd-3233-4b15-bc72-1460b5400f8e)
![image](https://github.com/user-attachments/assets/fa335036-9928-4b90-96d7-1c9ae0e8a3e1)


---

## Conclusion
The project successfully implemented a responsive, user-friendly main screen with a focus on layout, scrolling behavior, and orientation adaptability. The use of Flutter's powerful layout and widget system allowed the team to create an engaging experience that is optimized for multiple screen sizes and orientations.
