#include <iostream>
#include <fstream>
#include <string>
#include <set>
using namespace std;
int main(){
	
	ifstream other("other.txt",ios::in);
	string s;
	set<string> arr; 
	while(getline(other,s)){
		//cout << s;
		arr.insert(s);
	}
	
	other.close();
	ifstream me("me.txt",ios::in);
	while(getline(me,s)){
		if(arr.find(s)==arr.end()) cout << s << '\n';
	}
	other.close();
	return 0;
} 
