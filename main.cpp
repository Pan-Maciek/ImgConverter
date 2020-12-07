#include <FreeImage.h>
#include <iostream>
#include <string>

using namespace std;

string change_extension(char* cpath) {
	string path(cpath);
	return path.substr(0, path.rfind('.')) + ".jpg";
}


void convert(char* path) {
	auto s = std::string(path).rfind('.');


	auto format = FreeImage_GetFileType(path, 0);
	if (format == FIF_UNKNOWN) {
		cout << "Nieznany typ pliku [" << path << "]" << endl;
		return;
	}

	FIBITMAP* image = FreeImage_Load(format, path);
	if (!image) {
		cout << "Do tego nie powinno dojœæ. [" << path << "]" << endl;
		return;
	}

	FIBITMAP* temp = FreeImage_ConvertTo24Bits(image);
	FreeImage_Unload(image);
	image = temp;

	auto out = change_extension(path);

	if (!FreeImage_Save(FIF_JPEG, image, out.c_str(), 0)) {
		cout << "Problem z zapisywaniem pliku. [" << path << "]" << endl;
	}
	FreeImage_Unload(image);
}


int main(int argc, char** argv) {
	FreeImage_Initialise();

	cout << FreeImage_GetCopyrightMessage() << endl;

	cout << "0/" << argc - 1;
	for (int i = 1; i < argc; i++) {
		char* path = argv[i];
		convert(path);
		cout << '\r' << i << '/' << argc - 1 << " [" << change_extension(path) << ']' << "                                           ";
	}
	cout << std::endl;

	return 0;
}