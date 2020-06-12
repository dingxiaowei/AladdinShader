Shader "AladdinShader/01 Propertied Shader" //指定Shader路径和名字
{
	Properties //属性
	{
		_Color("Color",Color)=(1,1,1,1)
		_Vector("Vector",Vector)=(1,2,3,4)
		_Int("Int",Int)=2
		_Float("Float",Float)=12.3 //不用加f
		_Range("Range",Range(1.0,10.0))=1.0 //范围类型
		_2D("Texture",2D)="white"{} //white是默认值，如果不选图的话 就是默认白色的图
		_Cute("Cute",Cube)="red"{} //如果用天空盒就用Cube 立方体纹理
		_3D("Texture",3D)="black"{} //3D纹理
	}
	SubShader //SubShader可以写很多个 显卡运行效果的时候 从第一个开始，如果第一个SubShader里面的效果都可以实现就使用第一个SubShader，如果显卡这个SubShader有的实现不了会往下找支持的SubShader
	{
		//至少含有一个Pass
		Pass {
			//在这里编写Shader代码 HLSLPROGRAM
			CGPROGRAM
			//使用CG语言编写Shader代码

			float4 _Color;//float4就是四个值 _Color要跟上面属性名字保持一致
			float4 _Vector;
			float _Int;
			float _Range;
			sampler2D _2D;
			samplerCube _Cube;
			sampler3D _3D;


			ENDCG
		}
	}
	FallBack  "VertexLit" //如果上面SubShader都不支持 则执行默认的Shader效果
}