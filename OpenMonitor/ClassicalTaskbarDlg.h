#pragma once
#include "TaskBarDlg.h"
class CClassicalTaskbarDlg :
    public CTaskBarDlg
{
public:

private:
    // Inherited from CTaskBarDlg
    virtual void AdjustTaskbarWndPos(bool force_adjust) override;
    void InitTaskbarWnd() override;
    void ResetTaskbarPos() override;
    virtual HWND GetParentHwnd() override;

private:
    CRect m_rcMinOri;   // Rectangle area of the minimized window in its initial state
    int m_left_space{};			// Left margin between the minimized window and the secondary window
    int m_top_space{};			// Top margin between the minimized window and the secondary window (used when taskbar is on the left or right side of the screen)
    HWND m_hBar;		// Handle of the taskbar window secondary container
    HWND m_hMin;		// Handle of the minimized window
    CRect m_rcBar;		// Rectangle area of the taskbar window in its initial state
    CRect m_rcMin;		// Rectangle area of the minimized window

    int m_last_width;	// Previous width used to detect width changes
    int m_last_height;	// Previous height used to detect height changes (used when taskbar is on the left or right side of the screen)

    // Inherited from CTaskBarDlg
    void CheckTaskbarOnTopOrBottom() override;
};

