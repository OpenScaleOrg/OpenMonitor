#pragma once
#include "DrawCommon.h"
#include "SkinFile.h"


// CSkinPreviewView view


class CSkinPreviewView : public CScrollView
{
	DECLARE_DYNCREATE(CSkinPreviewView)

protected:
	CSkinPreviewView();           // Protected constructor used for dynamic creation
	virtual ~CSkinPreviewView();

public:
//#ifdef _DEBUG
//	virtual void AssertValid() const;
//#ifndef _WIN32_WCE
//	virtual void Dump(CDumpContext& dc) const;
//#endif
//#endif

//Member functions
public:
	void InitialUpdate();
	void SetSize(int width, int hight);
	void SetSkinData(CSkinFile* skin_data) { m_skin_data = skin_data; }

	//Member variables
protected:
	CSize m_size;
	CPoint m_start_point;			//Starting position for drawing

    CSkinFile* m_skin_data;

protected:
	virtual void OnDraw(CDC* pDC);      // Overridden to draw this view
	virtual void OnInitialUpdate();     // First call after construction

	DECLARE_MESSAGE_MAP()
};


