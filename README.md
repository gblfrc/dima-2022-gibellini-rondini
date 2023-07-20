# Frunds, run with friends!

This repository contains the code and the deliverables realized as a university project for the course of Design and Implementation of Mobile Application (DIMA), held at [Politecnico di Milano](https://polimi.it) in fall 2022.

This file aims at simply resuming how to correctly setup the application and providing the necessary basic insights in the application structure. For a deeper understanding of all the application features, please see the documentation deliverable.

**DISCLAIMER:** The DIMA course is evaluated solely on the project that the candidates show the professor during the exam session. In addition, according to the rules for the 2022-23 edition of the course, the application topic had to be initially agreed upon with the professor. Given the relevance of the project in the course work, any form of plagiarism is highly discouraged and the authors DO NOT hold accountable for any unpleasant situation stemming thereof.

## Setup
The authors fully developed the application with the [Android Studio IDE](https://developer.android.com/studio). Therefore, the structure of this folder complies to that of a generic Flutter project initialized within such IDE and the setup instructions reported herein refer to a setup within such software.

To run the application:
- clone this repository as a Flutter project;
- run `pub get` and obtain or update all the necessary dependencies;
- launch the application on an emulator.

Given the devices owned by the authors of this project, the application was tested and resulted to run successfully also on physical Android devices. No tests could be performed on iOS devices.

## External services
In order to provide all the designed functionalities, the application relies on some external services. In particular:
- **Firebase**, a Google suite providing several services. Specifically, this application leverages:
  - **Firestore**, a non-relational database storing all the data that users might produce;
  - **Auth**, to provide authentication services;
  - **Storage**, to keep the profile pictures which might be uploaded by the users;
  - **Cloud Functions**, a service for customizable back-end functions which have been used to replicate on Firestore the mechanism which is typical of triggers in relational databases.
- **Algolia**, a powerful search engine on which a single index was initialized to allow an easy retrieval of users with the related search function inside the application;
- **LocationIQ**, an online provider of location information, used to browse for places in the OpenStreetMap database to extend the possibilities of the search functionality.

In order to adopt these services, the authors subscribed to the free base plans offered by each of them. Later in the development process, when the Cloud Functions were introduced, it became necessary to update the Google plan to the pay-as-you-go version. However, this still resulted in no additional cost for the authors. 

On the 20th July 2023, the billing account associated to the Google services was closed before making this repository public, in order to avoid any potential future cost. As a consequence of this, the Cloud Functions and their trigger behavior are not supported anymore by the application. This decision should not severely impact the correct behavior of the application, since all the other functionalities are still supported, but will result in some discrepancy between the information provided by the user and the one visible in certain parts of the application.

## Testing

For this project, a deep testing campaing was carried out. This consisted of around 270 tests in the contexts of Unit Testing and Widget Testing[^testing]. The campaign resulted in an overall line coverage of 98%.

Given that the application strongly relies on external service, the testing process required the introduction of mocks. For this reason, the tests were generally carried out with the support of a pair of libraries:
- **Mockito**, providing complete support to the mechanism of mocks and their method stubbing;
- **build_runner**, allowing the automatic creation of mock objects and providing support for null safety[^nullsafety].

The files containing the mocks which are necessary to run the tests have not been uploaded in this repository, since they can be easily obtained by any user. In order to create those files and, therefore, to successfully run the tests, it is mandatory to run, first, the following command:

`dart run build_runner build`

## Grading

This project was presented during the June 2023 exam session, and it received a grading of 30L.

## Authors
- [Gibellini Federico](https://github.com/gblfrc)
- [Rondini Luca](https://github.com/LucaRondini)

[^testing]: For an introduction to testing in Flutter application and its taxonomy, please see the official reference from the Flutter docs, available at this [link](https://docs.flutter.dev/testing). 
[^nullsafety]: For a deep explanation of the use of the *build_runner* library, please see [this readme](https://github.com/dart-lang/mockito/blob/master/NULL_SAFETY_README.md) about null-safety published in the Mockito repository.
