Shader "AladdinShader/53 OutLine Shader"
{
    Properties
    {
        _MainTex("Main Tex", 2D) = "white"{}
        _Outline("Outline",Range(0,0.025))=0.01
        _OutlineColor("Outline Color", Color)=(0,0,1,1)
    }
    SubShader {
        Tags{"RenderType"="Opaque"}
        LOD 100
        Pass {
            Cull Front //面相摄像机的去掉
            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag 

            sampler2D _MainTex;
            fixed _Outline;
            fixed4 _OutlineColor;

            struct a2v{
                fixed4 vertex:POSITION;
                fixed4 normal:NORMAL;
            };

            struct v2f{
                fixed4 svPos:SV_POSITION;
            };

            v2f vert(a2v v)
            {
                v2f f;
                v.vertex.xyz += v.normal * _Outline;
                f.svPos = UnityObjectToClipPos(v.vertex);
                return f;
            }
            fixed4 frag(v2f f):SV_Target
            {
                return _OutlineColor;
            }
            ENDCG
        }
        Pass{
            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag 

            sampler2D _MainTex;

            struct a2v{
                fixed4 vertex:POSITION;
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