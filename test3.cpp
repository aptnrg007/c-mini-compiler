#include <iostream>
using namespace std;

class test
{
public :
  int a1,b1;
public:
  int t1(){
    return a1+b1;
  }
  int t2(){
    return a1*b1;
  }
  
}ob1,ob2;

void test::n21(){
int ba;
} 

int main() {
  int a=9;
  int j=20;
  int d1;
  //int p[20];
  float f,f1;
  char b,c;
     //   char b3[20]="asd";
 for(int i=0;i<a;i++){
    if(i<5){
      d1=a++;
      for(int k=j;k>0;k--){
        j=j-1;
      }
    }
    else if(i==5){
      f=f+2.0;
    }
    else{
      d1=a--;
    }
  }  
   return 0;
}
