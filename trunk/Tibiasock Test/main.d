module main;

import tibia.tibiasock;
import tibia.packet;
import tibia.winapi;
import core.thread;
import core.time;
import std.process;
import std.random;
import std.stdio;
import std.utf;

const DESIRED_ACCESS = (PROCESS_CREATE_THREAD | PROCESS_QUERY_INFORMATION | PROCESS_VM_OPERATION | PROCESS_VM_WRITE | PROCESS_VM_READ);

//Tibia 9.71 addresses
const sendStream = 0x3BADB8;
const sendDataLength = 0x5D53A8;
const sendToServerFunc = 0x11A2D0;

const parserFunc = 0x67F90;
const recvStream = 0x5D5394;

int main(string[] argv)
{
	uint procID;
	while(!procID)
	{
		system("Cls");
		writeln("Please start Tibia and login to begin the test.");
		system("Pause");
		procID = FindProcessByWindowName(("Tibia\0"w).dup);
	}

	HANDLE process = OpenProcess(DESIRED_ACCESS, 0, procID);

	auto baseAddress = getProcessImageBase(process);

	auto clientMsg = "Testing Incoming Injection".dup;
	auto serverMsg = "Testing OI".dup;


	for(int i = 0; i < 1_000; i++)
	{
		auto p = new Packet();
		p.add!(ubyte)(0x96);
		p.add!(ubyte)(0x01);
		p.add!(ushort)(cast(ushort)serverMsg.length);
		p.add!(char[])(serverMsg);
		sendPacketToServerEx(process, p.getRawPacket, 
							 baseAddress + sendStream, 
							 baseAddress + sendDataLength, 
							 baseAddress + sendToServerFunc);
		//Unnecessary since the D runtime does gargage collection by default
		//destroy(p);


		
		p = new Packet();
		p.add!(ubyte)(0xB4);
		p.add!(ubyte)(0x11);
		p.add!(ushort)(cast(ushort)clientMsg.length);
		p.add!(char[])(clientMsg);
		sendPacketToClientEx(process, p.getRawPacket, 
							 baseAddress + recvStream, 
							 baseAddress + parserFunc);
		//Unnecessary since the D runtime does gargage collection by default
		//destroy(p);

		//will make you get muted by the server
		Thread.sleep(dur!"msecs"(uniform(700,1600)));
	}

	CloseHandle(process);
	return 0;
}

uint FindProcessByWindowName(wchar[] windowName)
{
	uint procID;
	HWND window = FindWindowW(cast(LPCWSTR) null,cast(LPCWSTR) windowName);

	if (window)
		GetWindowThreadProcessId(window, &procID);

	return procID;
}
