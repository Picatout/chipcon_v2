/*---------------------------------------------------------------------------
* Copyright 2014, 2015 Jacques Deschênes
* This file is part of CHIPcon v2.
*
*     CHIPcon is free software: you can redistribute it and/or modify
*     it under the terms of the GNU General Public License as published by
*     the Free Software Foundation, either version 3 of the License, or
*     (at your option) any later version.
*
*     CHIPcon is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
*     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*     GNU General Public License for more details.
*
*     You should have received a copy of the GNU General Public License
*     along with CHIPcon.  If not, see <http://www.gnu.org/licenses/>.
*
*--------------------------------------------------------------------------
*/
/*
 * Created by SharpDevelop.
 * User: Jacques
 * Date: 2014-11-07
 * Time: 14:54
 * 
 * To change this template use Tools | Options | Coding | Edit Standard Headers.
 */
using System;
using System.Threading;
	
namespace ccemul
{
	/// <summary>
	/// Description of Keypad.
	/// </summary>

	public class Keypad
	{
		
	    internal const byte KEY_COUNT=5;
		
		byte[] hkeys=new byte[KEY_COUNT]
		{
		0x47, // UP
        0x42, // DOWN
        0x56, // LEFT
        0x4e, //RIGHT
        0x20, // FIRE        
		};
		
		internal ushort keys_state=0; // état des touches
		internal bool fWaitKey=false;
		
		public Keypad()
		{
		}

		
		internal byte keypadRead()
		{
			for (byte i=0;i<KEY_COUNT;i++){
				if ((keys_state & (1<<(i+1)))==(1<<(i+1)))
				{
				     	keys_state &=(ushort)(~(1<<(i+1))&0xffff);
					return (byte)(1<<(i+1));
				}
			}
			return 255;
		}
		
		internal byte waitKey()
		{
			if (keys_state==0)
			{
				fWaitKey=true;
				return 255;
			}else
				return keypadRead();
		}

		internal bool hexKeyDown(byte k)
		{
			byte i;
			
			for (i=0;i<KEY_COUNT;i++) if (hkeys[i]==k)
			{				
				keys_state|=(ushort)(1<<(i+1));
				return true;
			}
			return false;
		}
		
		internal bool hexKeyUp(byte k)
		{
			byte i=0;
			
			for (i=0;i<KEY_COUNT;i++) if (hkeys[i]==k)
			{				
				keys_state &=(ushort)(~(1<<(i+1))&0xffff);
				return true;
			}
			return false;
		}
		
		/*
 
		void prompt_key()
		{
			
		}
        */		
		internal bool keypad_break(){
       		return (((keys_state&6)==6) || ((keys_state & 24)==24));
		}
		
		internal bool keyDown(byte k)
		{
			return (keys_state & k)==k;
		}
	}
}
