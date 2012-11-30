module tibia.packet;

import std.traits;



const defaultCapacity = 1024;

public class Packet
{
	public:
		this(int initialCapacity)
		{
			mBody = new ubyte[initialCapacity];
		}
		this()
		{
			mBody = new ubyte[defaultCapacity];	
		}

		@property uint size()
		{
			return mPacketSize;
		}
		@property uint rawSize()
		{
			return mPacketSize + 2;
		}
		@property uint position()
		{
			return mCurrentPos;
		}

		void add(T)(T value)
		{
			static if(is(typeof(T[0])))
			{
				if(value.ptr !is null && value.length > 0)
				{
					int len = value.length * value[0].sizeof;
					if((mCurrentPos + len) >= mBody.length)
					{
						mBody.length *= 2;
					}

					mBody[mCurrentPos..mCurrentPos+len]= (cast(ubyte*)value.ptr)[0..len];
					mCurrentPos += len;
					mPacketSize += len;
				}
			}
			else
			{
				int len = value.sizeof;
				if((mCurrentPos + len) >= mBody.length)
				{
					mBody.length *= 2;
				}

				*cast(T*)(mBody.ptr + mCurrentPos)= value;
				mCurrentPos += len;
				mPacketSize += len;

			}	
		}		
		T read(T)() if(!isArray!(T))
		{
			T buffer;
			int len = T.init.sizeof;
			enforce((mCurrentPos + len) < mBody.length, "can not read outside the internal packet buffer"); 

			buffer = *cast(T*)(mBody.ptr + mCurrentPos);
			mCurrentPos += len;			
		}
		T peek(T)() if(!isArray!(T))
		{
			T buffer;
			int len = T.init.sizeof;
			enforce((mCurrentPos + len) < mBody.length, "can not read outside the internal packet buffer"); 

			buffer = *cast(T*)(mBody.ptr + mCurrentPos);
		}
		ubyte[] getPacket(){
			return [cast(ubyte)(mPacketSize & 0xFF), 
			cast(ubyte)((mPacketSize & 0xFF00)>>8)] ~ mBody.dup;
		}
		ubyte[] getRawPacket(){
			return mBody[0..mPacketSize].dup;
		}
		

	private:
		ubyte[] mBody;
		ubyte[] mOut;
		ushort mPacketSize;
		ushort mCurrentPos;
}