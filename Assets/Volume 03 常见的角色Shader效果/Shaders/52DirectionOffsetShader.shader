Shader "AladdinShader/52 DirectionOffset Shader"
{
    Properties
    {
        _MainTex("Main Tex", 2D) = "white"{}
        _Color("Color", Color) = (1,0,0,1)
        _Pos("Pos", Range(-1,1)) = 0.1
        _Range("Range", Range(0,2)) = 0.2
        _Scale("Scale", Range(0,0.05)) = 0.02
    }
    SubShader {
        Tags{"RenderType"="Opaque"}
        LOD 100
        Pass{
            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag 

            sampler2D _MainTex;
            fixed4 _Color;
            fixed _Pos;
            fixed _Range;
            fixed _Scale;

            //顶点函数参数
            struct a2v{
                fixed4 vertex:POSITION;
                fixed2 uv:TEXCOORD0; 
                fixed4 normal:NORMAL;
            };

            struct v2f{
                fixed4 svPos:SV_POSITION;
                fixed2 uv:TEXCOORD1;
                fixed4 color:COLOR;
            };

            v2f vert(a2v v)
            {
                v2f f;
          		f.uv = v.uv;
          		if(v.vertex.z <= _Pos && v.vertex.z >= _Pos - _Range)
                {
                    f.color = _Color;
                    v.vertex.xyz += v.normal * _Scale;
                }
                else
                {
                    f.color = fixed4(1,1,1,1); //默认就是白色
                }
                f.svPos = UnityObjectToClipPos(v.vertex);
                return f;
            } 

            fixed4 frag(v2f f):SV_Target{
                return tex2D(_MainTex,f.uv) * f.color;
            }
            ENDCG
        }
    }
    FallBack  "Specular"
}