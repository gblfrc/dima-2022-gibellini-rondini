import 'package:file_picker/file_picker.dart';

/*
* This class is meant to act as a wrapper to the FilePicker functionality to select an image
* from the device filesystem.
*/
class ImagePicker {
  /*
  * Method to select an image from teh filesystem. It allows the user to select a single image.
  * The method returns the path to the chosen file or, in case no file was chosen, null.
  */
  Future<String?> pickImage() async {
    try {
      var result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.image,
      );
      if (result != null) {
        return result.files.single.path!;
      } else {
        return null;
      }
    } on Exception {
      return null;
    }
  }
}
