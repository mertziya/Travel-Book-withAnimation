# Travel-Book-withAnimation

## Learning Objectives:
### Implementing basic CRUD operations with with the ***Core Data***
  - 'Create Operation' is called from the CoreDataService after user enters all the data needed (location name, country name, latitude, longitude) and enters the 'Kaydet' button.
  - 'Red Operation' is called from the CoreDataService when the view controller first loads and when there is an update happened in the **Core Data**. This fetching from the
    Core Data only when an update occured is assured by using the **Notification Pattern**
  - 'Update Operation' is called from the CoreDataService after user updates the already existing data fetched to the **UITextField** on the screen.
  - 'Delete Operation' is called from CoreDataService when the a row at the table view cell is swiped to left.

    
### Map Kit:
* Adding point annotation to the screen with the help of **UILongPressGestureRecognizer**.
* Openning the coordinate with the latitude and longitude values on an external map.

### Core Animation:
* Adding a shaking animation to the **UITextField**, if the user edits the text without changing the content. Main reason of that is showing the user skipped a step.
  This functionality is supplemented with showing a small red **UILabel** on the screen. Later, user is informed that the operation is done by showing a green label on the screen.
  

## Demo:

[Full Video](https://www.dropbox.com/scl/fi/mkj56ct8wnzc00mm7e2xa/TravelBookDemo.mp4?rlkey=f01im7k778h22s51zyjhxwkyi&st=7i4k0bsv&dl=0)

____


![trim 022070C8-4C85-41E1-8315-47BD2C277CF7-2](https://github.com/user-attachments/assets/75a35203-30f4-42b9-a6aa-e424df13b8f1)







