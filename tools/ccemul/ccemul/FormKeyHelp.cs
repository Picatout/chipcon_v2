/*
 * Created by SharpDevelop.
 * User: Jacques
 * Date: 2015-08-14
 * Time: 21:49
 * 
 * To change this template use Tools | Options | Coding | Edit Standard Headers.
 */
using System;
using System.Drawing;
using System.Windows.Forms;

namespace ccemul
{
	/// <summary>
	/// Description of FormKeyHelp.
	/// </summary>
	public partial class FormKeyHelp : Form
	{
		public FormKeyHelp()
		{
			//
			// The InitializeComponent() call is required for Windows Forms designer support.
			//
			InitializeComponent();
			
			//
			// TODO: Add constructor code after the InitializeComponent() call.
			//
		}
		void Button1Click(object sender, EventArgs e)
		{
			Close();
		}
	}
}
