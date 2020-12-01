#include <windows.h>
#include <stdlib.h>
#include <string.h>
#include <tchar.h>
#include <WindowsX.h>
#include <vector>
#include <queue>
#include <d2d1.h>
using namespace std;

#define ID_COMBOBOX_1 10001
#define ID_COMBOBOX_2 10002
#define ID_COMBOBOX_3 10003
#define ID_BUTTON_1 10004

const int x_size = 1000, y_size = 700;

static TCHAR szWindowClass[] = _T("DesktopApp");
static TCHAR szTitle[] = _T("Paint");

HWND hwnd;
HDC hdc;
HINSTANCE hInst;

LRESULT CALLBACK WndProc(HWND, UINT, WPARAM, LPARAM);
void OnLButtonDown(int x, int y);
void OnLButtonUp(int x, int y);
void OnMouseMove(int x, int y);
void GFill(HDC hdc, int x, int y);

enum class MODES {
    PEN,
    ERASER,
    FILL,
    GRADIENT,
    ELLIPSE,
    RECT
};
MODES mode = MODES::PEN;
COLORREF color = RGB(0, 0, 0);
int width = 3;

struct LINE {
    INT x1, y1, x2, y2;
};

bool mouse_down = false;
POINT ptPr;

HWND hWndComboBox1;
HWND hWndComboBox2;
HWND hWndComboBox3;

int CALLBACK WinMain(
    _In_ HINSTANCE hInstance,
    _In_opt_ HINSTANCE hPrevInstance,
    _In_ LPSTR     lpCmdLine,
    _In_ int       nCmdShow
)
{
    WNDCLASSEX wcex;

    wcex.cbSize = sizeof(WNDCLASSEX);
    wcex.style = CS_HREDRAW | CS_VREDRAW;
    wcex.lpfnWndProc = WndProc;
    wcex.cbClsExtra = 0;
    wcex.cbWndExtra = 0;
    wcex.hInstance = hInstance;
    wcex.hIcon = LoadIcon(hInstance, IDI_APPLICATION);
    wcex.hCursor = LoadCursor(NULL, IDC_ARROW);
    wcex.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);
    wcex.lpszMenuName = NULL;
    wcex.lpszClassName = szWindowClass;
    wcex.hIconSm = LoadIcon(wcex.hInstance, IDI_APPLICATION);

    if (!RegisterClassEx(&wcex))
    {
        MessageBox(NULL, _T("Call to RegisterClassEx failed!"), 
                  _T("Windows Desktop Guided Tour"), NULL);
        return 1;
    }

    hInst = hInstance;

    HWND hWnd = CreateWindow(szWindowClass, szTitle, WS_OVERLAPPEDWINDOW,
                             CW_USEDEFAULT, CW_USEDEFAULT, x_size, y_size, NULL,
                             NULL, hInstance, NULL);

    if (!hWnd)
    {
        MessageBox(NULL, _T("Call to CreateWindow failed!"),
                   _T("Windows Desktop Guided Tour"), NULL);

        return 1;
    }   

    //mode
    hWndComboBox1 = CreateWindow(L"COMBOBOX", NULL, WS_VISIBLE | WS_CHILD | CBS_DROPDOWN,
        10, 10, 100, 800, hWnd, (HMENU)ID_COMBOBOX_1,
        (HINSTANCE)GetWindowLong(hWnd, GWL_HINSTANCE), NULL);

    SendMessage(hWndComboBox1, CB_ADDSTRING, 0, (LPARAM)L"pen");
    SendMessage(hWndComboBox1, CB_ADDSTRING, 0, (LPARAM)L"eraser");
    SendMessage(hWndComboBox1, CB_ADDSTRING, 0, (LPARAM)L"fill");
    SendMessage(hWndComboBox1, CB_ADDSTRING, 0, (LPARAM)L"gradient fill");
    SendMessage(hWndComboBox1, CB_ADDSTRING, 0, (LPARAM)L"ellipse");
    SendMessage(hWndComboBox1, CB_ADDSTRING, 0, (LPARAM)L"rect");

    SendMessage(hWndComboBox1, CB_SETCURSEL, (WPARAM)0, (LPARAM)0);

    //color
    hWndComboBox2 = CreateWindow(L"COMBOBOX", NULL, WS_VISIBLE | WS_CHILD | CBS_DROPDOWN,
        120, 10, 100, 800, hWnd, (HMENU)ID_COMBOBOX_2,
        (HINSTANCE)GetWindowLong(hWnd, GWL_HINSTANCE), NULL);

    SendMessage(GetDlgItem(hWnd, ID_COMBOBOX_2), CB_ADDSTRING, 0, (LPARAM)L"black");
    SendMessage(GetDlgItem(hWnd, ID_COMBOBOX_2), CB_ADDSTRING, 0, (LPARAM)L"red");
    SendMessage(GetDlgItem(hWnd, ID_COMBOBOX_2), CB_ADDSTRING, 0, (LPARAM)L"green");
    SendMessage(GetDlgItem(hWnd, ID_COMBOBOX_2), CB_ADDSTRING, 0, (LPARAM)L"blue");
    SendMessage(GetDlgItem(hWnd, ID_COMBOBOX_2), CB_ADDSTRING, 0, (LPARAM)L"yellow");
    SendMessage(GetDlgItem(hWnd, ID_COMBOBOX_2), CB_ADDSTRING, 0, (LPARAM)L"purple");
    SendMessage(GetDlgItem(hWnd, ID_COMBOBOX_2), CB_ADDSTRING, 0, (LPARAM)L"orange");
    SendMessage(GetDlgItem(hWnd, ID_COMBOBOX_2), CB_ADDSTRING, 0, (LPARAM)L"pink");
    SendMessage(GetDlgItem(hWnd, ID_COMBOBOX_2), CB_ADDSTRING, 0, (LPARAM)L"gray");
    SendMessage(GetDlgItem(hWnd, ID_COMBOBOX_2), CB_ADDSTRING, 0, (LPARAM)L"brown");
    SendMessage(GetDlgItem(hWnd, ID_COMBOBOX_2), CB_ADDSTRING, 0, (LPARAM)L"white");

    SendMessage(hWndComboBox2, CB_SETCURSEL, (WPARAM)0, (LPARAM)0);
    
    //width
    hWndComboBox3 = CreateWindow(L"COMBOBOX", NULL, WS_VISIBLE | WS_CHILD | CBS_DROPDOWN,
        230, 10, 100, 800, hWnd, (HMENU)ID_COMBOBOX_3,
        (HINSTANCE)GetWindowLong(hWnd, GWL_HINSTANCE), NULL);

    SendMessage(GetDlgItem(hWnd, ID_COMBOBOX_3), CB_ADDSTRING, 0, (LPARAM)L"1");
    SendMessage(GetDlgItem(hWnd, ID_COMBOBOX_3), CB_ADDSTRING, 0, (LPARAM)L"3");
    SendMessage(GetDlgItem(hWnd, ID_COMBOBOX_3), CB_ADDSTRING, 0, (LPARAM)L"5");
    SendMessage(GetDlgItem(hWnd, ID_COMBOBOX_3), CB_ADDSTRING, 0, (LPARAM)L"10");
    SendMessage(GetDlgItem(hWnd, ID_COMBOBOX_3), CB_ADDSTRING, 0, (LPARAM)L"100");

    SendMessage(hWndComboBox3, CB_SETCURSEL, (WPARAM)1, (LPARAM)0);

    //button
    HWND hwndButton = CreateWindow(L"BUTTON", L"clear all", WS_TABSTOP | WS_VISIBLE | WS_CHILD | BS_DEFPUSHBUTTON,
        340, 10, 100, 24, hWnd, (HMENU)ID_BUTTON_1,
        (HINSTANCE)GetWindowLongPtr(hWnd, GWLP_HINSTANCE), NULL);
    
    ShowWindow(hWnd, nCmdShow);
    UpdateWindow(hWnd);

    hwnd = hWnd;
    hdc = GetDC(hWnd);

    MSG msg;
    while (GetMessage(&msg, NULL, 0, 0))
    {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }

    return (int)msg.wParam;
}



LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
    PAINTSTRUCT ps;
    HDC hdct;
    TCHAR greeting[] = _T("Hello, Windows desktop!");

    switch (message)
    {
    case WM_PAINT:
        hdct = BeginPaint(hWnd, &ps);

        hdct = hdc;

        EndPaint(hWnd, &ps);
        break;
    case WM_DESTROY:
        PostQuitMessage(0);
        break;
    case WM_LBUTTONDOWN:
        OnLButtonDown(LOWORD(lParam), HIWORD(lParam));
        return 0;

    case WM_LBUTTONUP:
        OnLButtonUp(LOWORD(lParam), HIWORD(lParam));
        return 0;
    case WM_MOUSEMOVE:
        OnMouseMove(LOWORD(lParam), HIWORD(lParam));
        return 0;
    case WM_COMMAND:

        if (HIWORD(wParam) == CBN_SELCHANGE)
        {
            int ind;
            switch (LOWORD(wParam)) {
            case ID_COMBOBOX_1:
                ind = SendMessage(hWndComboBox1, (UINT)CB_GETCURSEL, (WPARAM)0, (LPARAM)0);
                switch (ind) {
                case 0:
                    mode = MODES::PEN;
                    break;
                case 1:
                    mode = MODES::ERASER;
                    break;
                case 2:
                    mode = MODES::FILL;
                    break;
                case 3:
                    mode = MODES::GRADIENT;
                    break;
                case 4:
                    mode = MODES::ELLIPSE;
                    break;
                case 5:
                    mode = MODES::RECT;
                    break;
                default:
                    break;
                }
                break;
            case ID_COMBOBOX_2:
                ind = SendMessage(hWndComboBox2, (UINT)CB_GETCURSEL, (WPARAM)0, (LPARAM)0);
                switch (ind) {
                case 0:
                    color = RGB(0, 0, 0);
                    break;
                case 1:
                    color = RGB(255, 0, 0);
                    break;
                case 2:
                    color = RGB(0, 255, 0);
                    break;
                case 3:
                    color = RGB(0, 0, 255);
                    break;
                case 4:
                    color = RGB(255, 255, 0);
                    break;
                case 5:
                    color = RGB(128, 0, 128);
                    break;
                case 6:
                    color = RGB(255, 127, 0);
                    break;
                case 7:
                    color = RGB(255, 192, 203);
                    break;
                case 8:
                    color = RGB(128, 128, 128);
                    break;
                case 9:
                    color = RGB(150, 75, 0);
                    break;
                case 10:
                    color = RGB(255, 255, 255);
                    break;
                default:
                    break;
                }
                break;
            case ID_COMBOBOX_3:
                ind = SendMessage(hWndComboBox3, (UINT)CB_GETCURSEL, (WPARAM)0, (LPARAM)0);
                switch (ind) {
                case 0:
                    width = 1;
                    break;
                case 1:
                    width = 3;
                    break;
                case 2:
                    width = 5;
                    break;
                case 3:
                    width = 10;
                    break;
                case 4:
                    width = 100;
                    break;
                default:
                    break;
                }
                break;
            default:
                break;
            }
        }
        if (LOWORD(wParam) == ID_BUTTON_1) {
            InvalidateRect(hWnd, NULL, TRUE);
        }
        break;
    default:
        return DefWindowProc(hWnd, message, wParam, lParam);
        break;
    }
    return 0;
}

void OnLButtonDown(int x, int y)
{
    switch (mode) {
    case MODES::PEN:
    {
        mouse_down = TRUE;
        ptPr.x = x;
        ptPr.y = y;
        return;
    }
    case MODES::ERASER:
    {
        mouse_down = TRUE;
        ptPr.x = x;
        ptPr.y = y;
        return;
    }
    case MODES::FILL:
    {
        HDC hdc = GetDC(hwnd);
        HBRUSH br = CreateSolidBrush(color);
        SelectObject(hdc, br);
        ExtFloodFill(hdc, x, y, GetPixel(hdc, x, y), FLOODFILLSURFACE);
        DeleteObject(br);
        ReleaseDC(hwnd, hdc);
        return;
    }
    case MODES::GRADIENT:
    {
        ptPr.x = x;
        ptPr.y = y;
        return;
    }
    case MODES::ELLIPSE:
    {
        ptPr.x = x;
        ptPr.y = y;
        return;
    }
    case MODES::RECT:
    {
        ptPr.x = x;
        ptPr.y = y;
        return;
    }
    default:
        return;
    }
}

void OnLButtonUp(int x, int y)
{
    switch (mode) {
    case MODES::PEN:
    {
        if (mouse_down) {
            HDC hdc = GetDC(hwnd);
            HPEN pen = CreatePen(PS_SOLID, width, color);
            SelectObject(hdc, pen);
            MoveToEx(hdc, ptPr.x, ptPr.y, NULL);
            LineTo(hdc, ptPr.x = x, ptPr.y = y);
            DeleteObject(pen);
            ReleaseDC(hwnd, hdc);
        }
        mouse_down = false;
        return;
    }
    case MODES::ERASER:
    {
        if (mouse_down) {
            HDC hdc = GetDC(hwnd);
            HPEN pen = CreatePen(PS_SOLID, width, RGB(255,255,255));
            SelectObject(hdc, pen);
            MoveToEx(hdc, ptPr.x, ptPr.y, NULL);
            LineTo(hdc, ptPr.x = x, ptPr.y = y);
            DeleteObject(pen);
            ReleaseDC(hwnd, hdc);
        }
        mouse_down = false;
        return;
    }
    case MODES::FILL:
    {
        return;
    }
    case MODES::GRADIENT:
    {
        HDC hdc = GetDC(hwnd);
        GFill(hdc, x, y);
        ReleaseDC(hwnd, hdc);
        return;
    }
    case MODES::ELLIPSE:
    {
        HDC hdc = GetDC(hwnd);
        HPEN pen = CreatePen(PS_SOLID, width, color);
        SelectObject(hdc, pen);
        int dx = abs(x - ptPr.x);
        int dy = abs(y - ptPr.y);
        Ellipse(hdc, ptPr.x - dx, ptPr.y - dy, ptPr.x + dx, ptPr.y + dy);
        DeleteObject(pen);
        ReleaseDC(hwnd, hdc);
        return;
    }
    case MODES::RECT:
    {
        HDC hdc = GetDC(hwnd);
        HPEN pen = CreatePen(PS_SOLID, width, color);
        SelectObject(hdc, pen);
        int dx = abs(x - ptPr.x);
        int dy = abs(y - ptPr.y);
        Rectangle(hdc, ptPr.x - dx, ptPr.y - dy, ptPr.x + dx, ptPr.y + dy);
        DeleteObject(pen);
        ReleaseDC(hwnd, hdc);
        return;
    }
    default:
        return;
    }
}

void OnMouseMove(int x, int y)
{
    switch (mode) {
    case MODES::PEN:
    {
        if (mouse_down)
        {
            HDC hdc = GetDC(hwnd);
            HPEN pen = CreatePen(PS_SOLID, width, color);
            SelectObject(hdc, pen);
            MoveToEx(hdc, ptPr.x, ptPr.y, NULL);
            LineTo(hdc, ptPr.x = x, ptPr.y = y);
            DeleteObject(pen);
            ReleaseDC(hwnd, hdc);
        }
        return;
    }
    case MODES::ERASER:
    {
        if (mouse_down)
        {
            HDC hdc = GetDC(hwnd);
            HPEN pen = CreatePen(PS_SOLID, width, RGB(255, 255, 255));
            SelectObject(hdc, pen);
            MoveToEx(hdc, ptPr.x, ptPr.y, NULL);
            LineTo(hdc, ptPr.x = x, ptPr.y = y);
            DeleteObject(pen);
            ReleaseDC(hwnd, hdc);
        }
        return;
    }
    case MODES::FILL:
    {
        return;
    }
    case MODES::GRADIENT:
    {
        return;
    }
    case MODES::ELLIPSE:
    {
        return;
    }
    case MODES::RECT:
    {
        return;
    }
    default:
        return;
    }
}

void GFill(HDC hdc, int x, int y)
{
    int sx = x, sy = y;
    COLORREF old_color = GetPixel(hdc, x, y);
    queue< pair<int,int> > q;
    q.push({ x,y });
    while (!q.empty()) 
    {
        pair<int, int> p = q.front(); q.pop();
        x = p.first; y = p.second;
        if (x < 0 || x >= x_size) continue;
        if (y < 0 || y >= y_size) continue;
        COLORREF tmp_color = GetPixel(hdc, x, y);
        if (tmp_color == old_color) {
            int t = abs((x - y) - (sx - sy)) % (52 + 51);
            if (t > 51) t = 51 * 2 - t;
            SetPixel(hdc, x, y, RGB(0, t * 5, 255 - t * 5));
            q.push({ x-1,y });
            q.push({ x,y-1 });
            q.push({ x+1,y });
            q.push({ x,y+1 });
        }
    }
}