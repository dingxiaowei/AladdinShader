Shader "AladdinShader/50 DirectionOffset Shader"
{
    Properties
    {
        _MainTex("Main Tex", 2D) = "white"{} //纹理贴图 默认白色
        _Scale("Scale", Range(0,0.006))=0.0006
    }
    SubShader {
        Pass{
            CGPROGRAM
#pragma vertex vert 
#pragma fragment frag 

            sampler2D _MainTex;
            fixed _Scale;

            //顶点函数参数
            struct a2v{
                fixed4 vertex:POSITION;
                fixed4 normal:NORMAL; 
                fixed2 uv:TEXCOORD0; 
            };

            struct v2f{
                fixed4 svPos:SV_POSITION;
                fixed2 uv:TEXCOORD1;
            };

            v2f vert(a2v v)
            {
                v2f f;
          		f.uv = v.uv;
          		v.vertex.xzy += _Scale * v.normal;
          		f.svPos = UnityObjectToClipPos(v.vertex);
                return f;
            } 

            fixed4 frag(v2f f):SV_Target{
                return tex2D(_MainTex,f.uv);
            }
            ENDCG
        }
    }
    FallBack  "Specular"
}