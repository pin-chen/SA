//Class: 1101 計算機系統管理 曾建超 曾亮齊
//Author: 陳品劭 109550206
//Date: 20211010
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
