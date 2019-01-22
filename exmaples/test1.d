#!/usr/bin/rdmd --shebang=-I../source -I.

import std.stdio;
import std.typecons;
import std.range;
import std.algorithm;


struct Q
{
    int q = 0;
    ~this()
    {
        writeln("~Q", q, " ");
    }
}

struct A
{
    int a = 0;
    int n = 0;
    RefCounted!Q u;

    this(int a)
    {
        u = Q(10);
        this.a = a;
        writeln("this(int a) ", a, " ", this.a, " ", this.n);
    }
    ~this()
    {
        writeln("~this", a, " ", this.n);
        
        writeln("u.q ", u.q);
    }
    this(this)
    {
        n++;
        this.a = a.move * 2;
        //this.u = u;
        //this.u = u.move;
        //a = 1;
        writeln("this(this) ", a, " ", this.a, " ", this.n);
    }

    //void __postblit() {}
}


pragma(msg, "A: " ~ __traits(allMembers, A).stringof);

void main()
{
   auto a = A(5);
   //a.writeln;
   auto b = a;
   auto c = a.move;
   //b.writeln;

   //Unique!A a = new A(5);
   //a.a.writeln;

   //auto b = a.move;
   //b.writeln;


}