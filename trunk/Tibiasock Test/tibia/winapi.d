module tibia.winapi;

public import std.c.windows.windows;


pragma(lib,"kernel32.lib");
pragma(lib,"user32.lib");



//kernel32
alias CreateProcessW	CreateProcess;
alias Module32FirstW	Module32First;
alias Module32NextW		Module32Next;
alias Process32FirstW	Process32First;
alias Process32NextW	Process32Next;

alias STARTUPINFOW		STARTUPINFO;
alias STARTUPINFO*		LPSTARTUPINFO;
alias PROCESS_INFORMATION *		LPPROCESS_INFORMATION ;


//user32
alias GetClassNameW GetClassName;
alias GetWindowLongW GetWindowLong;

alias MODULEENTRY32W	MODULEENTRY32;
alias PROCESSENTRY32W	PROCESSENTRY32;
alias MODULEENTRY32W*	LPMODULEENTRY32W;
alias PROCESSENTRY32W*	LPPROCESSENTRY32W;




extern(Windows)
{
	//kernel32
	BOOL	CreateProcessW					(LPCWSTR, LPWSTR, LPSECURITY_ATTRIBUTES, LPSECURITY_ATTRIBUTES,
											 BOOL, DWORD, PVOID, LPCWSTR, LPSTARTUPINFOW, LPPROCESS_INFORMATION);
	HANDLE	CreateRemoteThread				(HANDLE, LPSECURITY_ATTRIBUTES, DWORD, LPTHREAD_START_ROUTINE,
											 LPVOID, DWORD, LPDWORD);
	HANDLE	CreateToolhelp32Snapshot		(DWORD,DWORD);
	BOOL	Module32FirstW					(HANDLE,LPMODULEENTRY32W);
	BOOL	Module32NextW					(HANDLE,LPMODULEENTRY32W);
	HANDLE	OpenProcess						(DWORD, BOOL, DWORD);
	HANDLE	OpenThread						(DWORD, BOOL, DWORD);
	BOOL	Process32FirstW					(HANDLE,LPPROCESSENTRY32W);
	BOOL	Process32NextW					(HANDLE,LPPROCESSENTRY32W);
	BOOL	ReadProcessMemory				(HANDLE, LPCVOID, LPVOID, DWORD, PDWORD);
	DWORD	ResumeThread					(HANDLE);
	DWORD	SuspendThread					(HANDLE);
	BOOL	WriteProcessMemory				(HANDLE, LPVOID, LPCVOID, SIZE_T, SIZE_T*);
	BOOL	TerminateProcess				(HANDLE, UINT);
	BOOL	TerminateThread					(HANDLE, DWORD);
	PVOID	VirtualAllocEx					(HANDLE, LPVOID, DWORD, DWORD, DWORD);
	BOOL	VirtualFreeEx					(HANDLE, LPVOID, DWORD, DWORD);
	BOOL	VirtualProtectEx				(HANDLE, LPVOID, DWORD, DWORD, PDWORD);
	alias DWORD function(LPVOID)			LPTHREAD_START_ROUTINE;


	//user32
	BOOL	EnumWindows						(WNDENUMPROC, LPARAM);
	HWND	FindWindowW						(LPCWSTR, LPCWSTR);
	int		GetClassNameW					(HWND, LPWSTR, int);
	LONG	GetWindowLongW					(HWND, int);
	DWORD	GetWindowThreadProcessId		(HWND, PDWORD);
	DWORD	WaitForInputIdle				(HANDLE, DWORD);
	alias BOOL function (HWND, LPARAM)      WNDENUMPROC;
}


struct VS_FIXEDFILEINFO {
	DWORD dwSignature;
	DWORD dwStrucVersion;
	DWORD dwFileVersionMS;
	DWORD dwFileVersionLS;
	DWORD dwProductVersionMS;
	DWORD dwProductVersionLS;
	DWORD dwFileFlagsMask;
	DWORD dwFileFlags;
	DWORD dwFileOS;
	DWORD dwFileType;
	DWORD dwFileSubtype;
	DWORD dwFileDateMS;
	DWORD dwFileDateLS;
}

struct STARTUPINFOW {
	DWORD  cb = STARTUPINFOW.sizeof;
	LPWSTR lpReserved;
	LPWSTR lpDesktop;
	LPWSTR lpTitle;
	DWORD  dwX;
	DWORD  dwY;
	DWORD  dwXSize;
	DWORD  dwYSize;
	DWORD  dwXCountChars;
	DWORD  dwYCountChars;
	DWORD  dwFillAttribute;
	DWORD  dwFlags;
	WORD   wShowWindow;
	WORD   cbReserved2;
	PBYTE  lpReserved2;
	HANDLE hStdInput;
	HANDLE hStdOutput;
	HANDLE hStdError;
}
alias STARTUPINFOW* LPSTARTUPINFOW;

struct PROCESS_INFORMATION {
	HANDLE hProcess;
	HANDLE hThread;
	DWORD  dwProcessId;
	DWORD  dwThreadId;
}

const uint CREATE_SUSPENDED = 0x00000004;

struct PROCESSENTRY32W {
	DWORD dwSize;
	DWORD cntUsage;
	DWORD th32ProcessID;
	DWORD th32DefaultHeapID;
	DWORD th32ModuleID;
	DWORD cntThreads;
	DWORD th32ParentProcessID;
	LONG pcPriClassBase;
	DWORD dwFlags;
	WCHAR szExeFile[MAX_PATH];
}

struct MODULEENTRY32W {
	DWORD dwSize;
	DWORD th32ModuleID;
	DWORD th32ProcessID;
	DWORD GlblcntUsage;
	DWORD ProccntUsage;
	BYTE *modBaseAddr;
	DWORD modBaseSize;
	HMODULE hModule; 
	WCHAR szModule[MAX_MODULE_NAME32 + 1];
	WCHAR szExePath[MAX_PATH];
}

const MAX_MODULE_NAME32 = 255;
const size_t MAX_PATH = 260;

const uint
	PROCESS_TERMINATE         = 0x0001,
	PROCESS_CREATE_THREAD     = 0x0002,
	PROCESS_SET_SESSIONID     = 0x0004,
	PROCESS_VM_OPERATION      = 0x0008,
	PROCESS_VM_READ           = 0x0010,
	PROCESS_VM_WRITE          = 0x0020,
	PROCESS_DUP_HANDLE        = 0x0040,
	PROCESS_CREATE_PROCESS    = 0x0080,
	PROCESS_SET_QUOTA         = 0x0100,
	PROCESS_SET_INFORMATION   = 0x0200,
	PROCESS_QUERY_INFORMATION = 0x0400,
	PROCESS_ALL_ACCESS        = STANDARD_RIGHTS_REQUIRED | SYNCHRONIZE | 0x0FFF;

const uint 
	TH32CS_SNAPHEAPLIST = 0x1,
	TH32CS_SNAPPROCESS  = 0x2,
	TH32CS_SNAPTHREAD   = 0x4,
	TH32CS_SNAPMODULE   = 0x8,
	TH32CS_SNAPALL      = (TH32CS_SNAPHEAPLIST|TH32CS_SNAPPROCESS|TH32CS_SNAPTHREAD|TH32CS_SNAPMODULE),
	TH32CS_INHERIT      = 0x80000000;

const uint
	THREAD_TERMINATE            = 0x0001,
	THREAD_SUSPEND_RESUME       = 0x0002,
	THREAD_GET_CONTEXT          = 0x0008,
	THREAD_SET_CONTEXT          = 0x0010,
	THREAD_SET_INFORMATION      = 0x0020,
	THREAD_QUERY_INFORMATION    = 0x0040,
	THREAD_SET_THREAD_TOKEN     = 0x0080,
	THREAD_IMPERSONATE          = 0x0100,
	THREAD_DIRECT_IMPERSONATION = 0x0200;