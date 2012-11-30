/+
/* Original author */
Tibiasock.dll by DarkstaR
Special thanks to the authors of the following pages:
/* tibiasock.d */
30/11/2012: Ported to the D programming language by Farsa(Geancarlo Rocha)
+/
module tibia.tibiasock;

import tibia.winapi;


public void sendPacketToClientEx(HANDLE process, ubyte[] dataBuffer, uint recvStream, uint parserCall){
	uint mainThreadId = getProcessMainThreadId(process);
	HANDLE mainThread = openAndSuspendThread(mainThreadId);

	uint dataPointer;
	int oldLength, oldPosition;
	ReadProcessMemory(process, cast(LPVOID)(recvStream + 4), &oldLength, 4, cast(uint*)null);
	ReadProcessMemory(process, cast(LPVOID)(recvStream + 8), &oldPosition, 4, cast(uint*)null);
	ReadProcessMemory(process, cast(LPVOID)recvStream, &dataPointer, 4, cast(uint*)null);
	auto oldDataBuffer= new ubyte[oldLength];
	ReadProcessMemory(process, cast(LPVOID)dataPointer, oldDataBuffer.ptr, oldLength, cast(uint*)null);
	//debug
	//{
	//    std.stdio.writefln("%X  %s  %s",dataPointer, oldLength, oldPosition);
	//    std.stdio.writeln(oldDataBuffer);
	//}
	WriteIncomingBuffer(process, recvStream, dataBuffer, 0); 
	//debug
	//{
	//    std.stdio.writefln("%X  %s  %s",dataPointer, dataBuffer.length, 0);
	//    std.stdio.writeln(dataBuffer);
	//}
	ubyte[10] codeCave = [0xB8, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xD0, 0xC3, 0x00, 0x00]; //MOV EAX, <DWORD> | CALL EAX | RETN
	*cast(uint*)&codeCave[1]=parserCall;
	LPVOID codeCavePointer = CreateRemoteBuffer(process, codeCave);

	executeRemoteCode(process, codeCavePointer, cast(LPVOID)0);

	VirtualFreeEx(process, codeCavePointer, 10, MEM_RELEASE);
	WriteIncomingBuffer(process, recvStream, oldDataBuffer, oldPosition); 

	resumeAndCloseThread(mainThread);
}
public void sendPacketToServerEx(HANDLE process, ubyte[] dataBuffer, uint sendStreamData, uint sendStreamLength, uint sendPacketCall){
	uint mainThreadId = getProcessMainThreadId(process);
	HANDLE mainThread = openAndSuspendThread(mainThreadId);

	int oldLength;
	ReadProcessMemory(process, cast(LPCVOID)sendStreamLength, &oldLength, 4, cast(uint*)null);
	ubyte[] oldData = new ubyte[oldLength];
	ReadProcessMemory(process, cast(LPCVOID)sendStreamData, oldData.ptr, oldLength, cast(uint*)null);

	auto length = dataBuffer.length + 8;
	auto actualBuffer = createOutgoingBuffer(dataBuffer);
	WriteProcessMemory(process, cast(LPVOID)sendStreamLength, &length, 4, cast(uint*)null);
	WriteProcessMemory(process, cast(LPVOID)sendStreamData, actualBuffer.ptr, length, cast(uint*)null);

	executeRemoteCode(process, cast(LPVOID)sendPacketCall, cast(LPVOID)1);

	WriteProcessMemory(process, cast(LPVOID)sendStreamLength, &oldLength, 4, cast(uint*)null);
	WriteProcessMemory(process, cast(LPVOID)sendStreamData, oldData.ptr, oldLength, cast(uint*)null);

	resumeAndCloseThread(mainThread);
}
public uint getProcessImageBase(HANDLE process)
{
	uint threadInfoBlock = getThreadInfoBlockPointer();
	uint processEnviromentBlock, imageBase;

	ReadProcessMemory(process, cast(LPVOID)(threadInfoBlock + 0x30), &processEnviromentBlock, 4, cast(uint*)null);
	ReadProcessMemory(process, cast(LPVOID)(processEnviromentBlock + 0x8), &imageBase, 4, cast(uint*)null);
	return imageBase;
}

private LPVOID CreateRemoteBuffer(HANDLE process, ubyte[] dataBuffer){
	LPVOID remoteBufferPointer = VirtualAllocEx(process, cast(LPVOID)null, dataBuffer.length, MEM_COMMIT, PAGE_EXECUTE_READWRITE);
	WriteProcessMemory(process, remoteBufferPointer, dataBuffer.ptr, dataBuffer.length, cast(uint*)null);
	return remoteBufferPointer;
}
private void WriteIncomingBuffer(HANDLE process, uint recvStream, ubyte[] data,uint position){
	uint dataPointer;
	uint length = data.length;
	WriteProcessMemory(process, cast(LPVOID)(recvStream + 4), &length, 4, cast(uint*)null);
	WriteProcessMemory(process, cast(LPVOID)(recvStream + 8), &position, 4, cast(uint*)null);

	ReadProcessMemory(process, cast(LPVOID)recvStream, &dataPointer, 4, cast(uint*)null);
	WriteProcessMemory(process, cast(LPVOID)dataPointer, data.ptr, length, cast(uint*)null);
}
private ubyte[] createOutgoingBuffer(ubyte[] dataBuffer){
	ubyte[] actualBuffer = new ubyte[dataBuffer.length + 8]; 
	actualBuffer[0..8] = 0;
	actualBuffer[8..actualBuffer.length] = dataBuffer.dup;
	return actualBuffer;
}
private HANDLE openAndSuspendThread(uint threadID)
{
	HANDLE thread = OpenThread((THREAD_GET_CONTEXT | THREAD_SUSPEND_RESUME | THREAD_SET_CONTEXT), false, threadID);
	SuspendThread(thread);
	return thread;
}
private void resumeAndCloseThread(HANDLE thread)
{
	ResumeThread(thread);
	CloseHandle(thread);
}
private void executeRemoteCode(HANDLE process, LPVOID codeAddress, LPVOID arg)
{
	HANDLE workThread = CreateRemoteThread(process,cast(SECURITY_ATTRIBUTES*) null, 0, cast(LPTHREAD_START_ROUTINE)codeAddress, arg, 0, cast(uint*)0);
	WaitForSingleObject(workThread, INFINITE);
	CloseHandle(workThread);
}
private uint getProcessMainThreadId(HANDLE process)
{
	uint threadInfoBlock = getThreadInfoBlockPointer();
	uint mainThreadId;

	ReadProcessMemory(process, cast(LPVOID)(threadInfoBlock + 0x24), &mainThreadId, 4, cast(uint*)null);
	return mainThreadId;
}
private uint getThreadInfoBlockPointer()
{
	uint threadInfoBlock;
	asm
	{
		mov EAX, FS:[0x18];
		mov [threadInfoBlock], EAX;
	}
	return threadInfoBlock;
}