#include <windows.h> 
#include <tchar.h>
#include <stdio.h> 
#include <strsafe.h>
#include <string>

#define BUFSIZE 1920*1080*4*4
 
HANDLE g_hProcess = NULL;
HANDLE g_hChildStd_IN_Rd = NULL;
HANDLE g_hChildStd_IN_Wr = NULL;
HANDLE g_hChildStd_ERR_Rd = NULL;
HANDLE g_hChildStd_ERR_Wr = NULL;
DWORD g_dwExitCode = NULL;

HANDLE hStderrThread = NULL;
typedef struct {
	HANDLE parentStdErr;
	HANDLE childStdErr;
	HANDLE childStdIn;
} StderrThreadData;
StderrThreadData stderrThreadData;

void CreateChildProcess(void);
void StartStderrThread(void);
DWORD WINAPI StderrThreadMain( LPVOID lpParam );
void WriteToPipe(void); 
void ReadFromPipe(void); 
void ErrorExit(PTSTR); 
 
int _tmain(int argc, TCHAR *argv[]) 
{ 
   SECURITY_ATTRIBUTES saAttr; 
 
// Set the bInheritHandle flag so pipe handles are inherited. 
 
   saAttr.nLength = sizeof(SECURITY_ATTRIBUTES); 
   saAttr.bInheritHandle = TRUE; 
   saAttr.lpSecurityDescriptor = NULL; 

// Create a pipe for the child process's STDOUT. 
 
   if ( ! CreatePipe(&g_hChildStd_ERR_Rd, &g_hChildStd_ERR_Wr, &saAttr, 0) ) 
      ErrorExit(TEXT("StdoutRd CreatePipe")); 

// Ensure the read handle to the pipe for STDOUT is not inherited.

   if ( ! SetHandleInformation(g_hChildStd_ERR_Rd, HANDLE_FLAG_INHERIT, 0) )
      ErrorExit(TEXT("Stdout SetHandleInformation")); 

// Create a pipe for the child process's STDIN. 
 
   if (! CreatePipe(&g_hChildStd_IN_Rd, &g_hChildStd_IN_Wr, &saAttr, 0)) 
      ErrorExit(TEXT("Stdin CreatePipe")); 

// Ensure the write handle to the pipe for STDIN is not inherited. 
 
   if ( ! SetHandleInformation(g_hChildStd_IN_Wr, HANDLE_FLAG_INHERIT, 0) )
      ErrorExit(TEXT("Stdin SetHandleInformation")); 
 
// Create the child process. 
   
   CreateChildProcess();

// Get a handle to an input file for the parent. 
// This example assumes a plain text file and uses string output to verify data flow. 
 
 
// Write to the pipe that is the standard input for a child process. 
// Data is written to the pipe's buffers, so it is not necessary to wait
// until the child process is running before writing data.
 
   //WriteToPipe(); 
 
   StartStderrThread();

// Read from pipe that is the standard output for child process. 
   ReadFromPipe(); 

   CloseHandle(hStderrThread);

// The remaining open handles are cleaned up when this process terminates. 
// To avoid resource leaks in a larger application, close handles explicitly. 


   return (int)g_dwExitCode; 
} 
 
void StartStderrThread()
{
	stderrThreadData.parentStdErr = GetStdHandle(STD_ERROR_HANDLE);
	stderrThreadData.childStdErr = g_hChildStd_ERR_Rd;
	stderrThreadData.childStdIn = g_hChildStd_IN_Wr;
	hStderrThread = CreateThread(NULL, 0, StderrThreadMain, &stderrThreadData, 0, NULL);
}


DWORD WINAPI StderrThreadMain( LPVOID lpParam )
{
	StderrThreadData data = *(StderrThreadData*)lpParam;
	const int STDERR_BUF_SIZE = 4096;
	char stderrBuf[4096];
	DWORD dwRead, dwWritten; 
	BOOL bSuccess;

	for(;;) {
	  // read output from stderr
      bSuccess = ReadFile( data.childStdErr, stderrBuf, STDERR_BUF_SIZE, &dwRead, NULL);
	  if( ! bSuccess || dwRead == 0 ) break;
	   //printf("stderr: %i", dwRead);
	  // fflush(stdout);
      bSuccess = WriteFile(data.parentStdErr, stderrBuf, 
                           dwRead, &dwWritten, NULL);
	  FlushFileBuffers(data.parentStdErr);
	  if (! bSuccess ) break;
	}

	CloseHandle(data.childStdIn);

	ExitThread(0);
}

void
ArgvQuote (
    const std::wstring& Argument,
    std::wstring& CommandLine,
    bool Force
    )
    
/*++
    
Routine Description:
    
    This routine appends the given argument to a command line such
    that CommandLineToArgvW will return the argument string unchanged.
    Arguments in a command line should be separated by spaces; this
    function does not add these spaces.
    
Arguments:
    
    Argument - Supplies the argument to encode.

    CommandLine - Supplies the command line to which we append the encoded argument string.

    Force - Supplies an indication of whether we should quote
            the argument even if it does not contain any characters that would
            ordinarily require quoting.
    
Return Value:
    
    None.
    
Environment:
    
    Arbitrary.
    
--*/
    
{
    //
    // Unless we're told otherwise, don't quote unless we actually
    // need to do so --- hopefully avoid problems if programs won't
    // parse quotes properly
    //
    
    if (Force == false &&
        Argument.empty () == false &&
        Argument.find_first_of (L" \t\n\v\"") == Argument.npos)
    {
        CommandLine.append (Argument);
    }
    else {
        CommandLine.push_back (L'"');
        
        for (auto It = Argument.begin () ; ; ++It) {
            unsigned NumberBackslashes = 0;
        
            while (It != Argument.end () && *It == L'\\') {
                ++It;
                ++NumberBackslashes;
            }
        
            if (It == Argument.end ()) {
                
                //
                // Escape all backslashes, but let the terminating
                // double quotation mark we add below be interpreted
                // as a metacharacter.
                //
                
                CommandLine.append (NumberBackslashes * 2, L'\\');
                break;
            }
            else if (*It == L'"') {

                //
                // Escape all backslashes and the following
                // double quotation mark.
                //
                
                CommandLine.append (NumberBackslashes * 2 + 1, L'\\');
                CommandLine.push_back (*It);
            }
            else {
                
                //
                // Backslashes aren't special here.
                //
                
                CommandLine.append (NumberBackslashes, L'\\');
                CommandLine.push_back (*It);
            }
        }
    
        CommandLine.push_back (L'"');
    }

	CommandLine.push_back (L' ');
}

void CreateChildProcess()
// Create a child process that uses the previously created pipes for STDIN and STDOUT.
{ 
   //TCHAR zaName[]=TEXT("ffmpeg.exe");

   int nArgs;
   LPWSTR* cmdLineArgs = CommandLineToArgvW(GetCommandLine(), &nArgs);

   std::wstring cmdLine;
   ArgvQuote(L"ffmpeg.exe", cmdLine, false);
   for(int i=1; i<nArgs; i++) {
		ArgvQuote(cmdLineArgs[i], cmdLine, false);
   }
   LocalFree(cmdLineArgs);

   PROCESS_INFORMATION piProcInfo; 
   STARTUPINFO siStartInfo;
   BOOL bSuccess = FALSE; 
 
// Set up members of the PROCESS_INFORMATION structure. 
 
   ZeroMemory( &piProcInfo, sizeof(PROCESS_INFORMATION) );
 
// Set up members of the STARTUPINFO structure. 
// This structure specifies the STDIN and STDOUT handles for redirection.
 
   ZeroMemory( &siStartInfo, sizeof(STARTUPINFO) );
   siStartInfo.cb = sizeof(STARTUPINFO); 
   siStartInfo.hStdError = g_hChildStd_ERR_Wr;
   siStartInfo.hStdOutput = g_hChildStd_ERR_Wr;
   siStartInfo.hStdInput = g_hChildStd_IN_Rd;
   siStartInfo.dwFlags |= STARTF_USESTDHANDLES;
 
// Create the child process. 
    
   bSuccess = CreateProcess(NULL, 
	  (LPWSTR)(cmdLine.c_str()),     // command line 
      NULL,          // process security attributes 
      NULL,          // primary thread security attributes 
      TRUE,          // handles are inherited 
      0,             // creation flags 
      NULL,          // use parent's environment 
      NULL,          // use parent's current directory 
      &siStartInfo,  // STARTUPINFO pointer 
      &piProcInfo);  // receives PROCESS_INFORMATION 
   
   CloseHandle(g_hChildStd_ERR_Wr);

   // If an error occurs, exit the application. 
   if ( ! bSuccess ) 
      ErrorExit(TEXT("CreateProcess"));
   else 
   {
      // Close handles to the child process and its primary thread.
      // Some applications might keep these handles to monitor the status
      // of the child process, for example. 
	   g_hProcess = piProcInfo.hProcess;
      CloseHandle(piProcInfo.hThread);
   }
}
 
void ReadFromPipe(void) 

// Read output from the child process's pipe for STDOUT
// and write to the parent process's pipe for STDOUT. 
// Stop when there is no more data. 
{ 
   DWORD dwRead, dwWritten; 
   void* buf;
   buf = malloc(BUFSIZE);
   BOOL bSuccess = FALSE;
   HANDLE hParentStdErr = GetStdHandle(STD_ERROR_HANDLE);
   HANDLE hParentStdOut = GetStdHandle(STD_OUTPUT_HANDLE);
   HANDLE hParentStdIn = GetStdHandle(STD_INPUT_HANDLE);

   for (;;) 
   { 
	  // write input to ffmpeg
	  bSuccess = ReadFile(hParentStdIn, buf, BUFSIZE, &dwRead, NULL);
      if ( ! bSuccess ) break; 

	  if(dwRead > 0) {
		bSuccess = WriteFile(g_hChildStd_IN_Wr, buf, dwRead, &dwWritten, NULL);
		if ( ! bSuccess ) break; 
	  }

	  printf("!");
	  fflush(stdout);
   }

   free(buf);
   CloseHandle(g_hChildStd_IN_Wr);
   CloseHandle(g_hChildStd_ERR_Rd);

   WaitForSingleObject(g_hProcess, INFINITE);

   GetExitCodeProcess(g_hProcess, &g_dwExitCode);
} 
 
void ErrorExit(PTSTR lpszFunction) 

// Format a readable error message, display a message box, 
// and exit from the application.
{ 
    LPVOID lpMsgBuf;
    LPVOID lpDisplayBuf;
    DWORD dw = GetLastError(); 

    FormatMessage(
        FORMAT_MESSAGE_ALLOCATE_BUFFER | 
        FORMAT_MESSAGE_FROM_SYSTEM |
        FORMAT_MESSAGE_IGNORE_INSERTS,
        NULL,
        dw,
        MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
        (LPTSTR) &lpMsgBuf,
        0, NULL );

    lpDisplayBuf = (LPVOID)LocalAlloc(LMEM_ZEROINIT, 
        (lstrlen((LPCTSTR)lpMsgBuf)+lstrlen((LPCTSTR)lpszFunction)+40)*sizeof(TCHAR)); 
    StringCchPrintf((LPTSTR)lpDisplayBuf, 
        LocalSize(lpDisplayBuf) / sizeof(TCHAR),
        TEXT("%s failed with error %d: %s"), 
        lpszFunction, dw, lpMsgBuf); 
    MessageBox(NULL, (LPCTSTR)lpDisplayBuf, TEXT("Error"), MB_OK); 

    LocalFree(lpMsgBuf);
    LocalFree(lpDisplayBuf);
    ExitProcess(1);
}
