Shader "AladdinShader/20 StreamerColor Shader"
{
       Properties
       {
              _Texture ("Texture", 2D) = "white" {}
              _Color("color",Color) = (1,0,0,1)
              _Pos("Pos",Range(-1,4)) = -0.3
              _Range("Range",Range(0,2)) = 0.2
       }
       SubShader
       {
              Tags { "RenderType"="Opaque" }
              LOD 100

              Pass
              {
                     CGPROGRAM
                     #pragma vertex vert
                     #pragma fragment frag


                     sampler2D _Texture;
                     fixed4 _Color;
                     fixed _Pos;
                     fixed _Range;


                     struct a2v
                     {
                           float4 vertex : POSITION;
                           float2 uv : TEXCOORD0;
                     } ;

                     struct v2f
                     {
                           fixed4 vertex : SV_POSITION;
                           float2 uv : TEXCOORD0;
                           fixed4 color : COLOR;
                     } ;

                     
                     v2f vert (a2v v)
                     {
                           v2f o;
                           o.uv = v.uv;

                           if(v.vertex.y <= _Pos && v.vertex.y >= _Pos - _Range)
                           {
                                  o.color = _Color;
                           }
                           else
                           {
                                  o.color = fixed4(1,1,1,1);
                           }

                           o.vertex = UnityObjectToClipPos(v.vertex);

                           return o;
                     }
                     
                     fixed4 frag (v2f i) : SV_Target
                     {
                           return tex2D(_Texture, i.uv) * i.color;
                     }
                     ENDCG
              }
       }
}