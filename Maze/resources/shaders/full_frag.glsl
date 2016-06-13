#version 330 core
struct Material {
    sampler2D diffuse2D;
    sampler2D specular2D;
    sampler2D normal2D;
    sampler2D depth2D;
    sampler2D occlusion2D;
	
	vec3 diffuse;
	vec3 specular;
	
    float shininess;
};

struct DirLight {
    vec3 direction;
	
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};

struct PointLight {
    vec3 position;
	
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
	
    float constant;
    float linear;
    float quadratic;
};

#define NR_POINT_LIGHTS 9

in vec3 FragPosition;
in vec2 TexCoord;
in mat3 TBN;

out vec4 color;

uniform vec3 ViewPosition;
uniform int NumberOfLights;
uniform DirLight directional;
uniform PointLight lights[NR_POINT_LIGHTS];
uniform Material material;

vec3 CalcDirLight(DirLight light, vec3 normal, vec3 viewDir, vec2 texCoord);
vec3 CalcPointLight(PointLight light, vec3 normal, vec3 fragPos, vec3 viewDir, vec2 texCoord);
vec2 ParallaxMapping(vec2 texCoords, vec3 vDir);

void main()
{
	vec3 result = vec3(0);
	
	vec3 fPos = TBN * FragPosition;
	vec3 vPos = TBN * ViewPosition;

    vec3 vDir = normalize(vPos - fPos);

	vec2 texCoord = TexCoord;
	//texCoord = ParallaxMapping(texCoord, vDir);
	//if(texCoord.x > 1.0 || texCoord.y > 1.0 || texCoord.x < 0.0 || texCoord.y < 0.0)
    //    discard;

	vec3 normal = vec3(texture(material.normal2D, texCoord));
	normal = normalize(normal * 2.0 - 1.0);
    
    result = CalcDirLight(directional, normal, vDir, texCoord);
	
    for(int i = 0; i < NumberOfLights; i++)
        result += CalcPointLight(lights[i], normal, fPos, vDir, texCoord);
    
	vec3 occlusion = vec3(texture(material.occlusion2D, texCoord));

    color = vec4(occlusion * result, 1.0);
}

// Calculate directional light pixel color
vec3 CalcDirLight(DirLight light, vec3 normal, vec3 vDir, vec2 texCoord)
{
	vec3 lDir = normalize(TBN * (-light.direction));

    float diff = max(dot(normal, lDir), 0.0);
    
    vec3 reflectDir = reflect(-lDir, normal);
    float spec = pow(max(dot(vDir, reflectDir), 0.0), material.shininess);
	
	vec3 ambient = light.ambient * vec3(texture(material.diffuse2D, texCoord));
	vec3 diffuse = light.diffuse * diff * vec3(texture(material.diffuse2D, texCoord));
	vec3 specular = light.specular * spec * vec3(texture(material.specular2D, texCoord));
    
	return (ambient + diffuse + specular);
}

// Calculate point light pixel color
vec3 CalcPointLight(PointLight light, vec3 normal, vec3 fPos, vec3 vDir, vec2 texCoord)
{
	vec3 lPos = TBN * light.position;
	vec3 lDir = normalize(lPos - fPos);

	float diff = max(dot(normal, lDir), 0.0);
    
    vec3 reflectDir = reflect(-lDir, normal);
    float spec = pow(max(dot(vDir, reflectDir), 0.0), material.shininess);
	
    float dst = length(lPos - fPos);

    float attenuation = 1.0f / (light.constant + light.linear * dst + light.quadratic * (dst * dst));
	
	vec3 ambient = light.ambient * vec3(texture(material.diffuse2D, texCoord));
	vec3 diffuse = light.diffuse * diff * vec3(texture(material.diffuse2D, texCoord));
	vec3 specular = light.specular * spec * vec3(texture(material.specular2D, texCoord));
    
	ambient *= attenuation;
    diffuse *= attenuation;
    specular *= attenuation;
    
	return (ambient + diffuse + specular);
}


vec2 ParallaxMapping(vec2 texCoords, vec3 vDir)
{ 
    const float minLayers = 8;
    const float maxLayers = 16;
	const float heightScale = 0.05;

    float numLayers = mix(maxLayers, minLayers, abs(dot(vec3(0.0, 0.0, 1.0), vDir)));

    float layerDepth = 1.0 / numLayers;

    float currentLayerDepth = 0.0;

    vec2 P = vDir.xy / vDir.z * heightScale; 
    vec2 deltaTexCoords = P / numLayers;
  
    vec2  currentTexCoords = texCoords;
    float currentDepthMapValue = texture(material.depth2D, currentTexCoords).r;
      
    while(currentLayerDepth < currentDepthMapValue)
    {
        currentTexCoords -= deltaTexCoords;
        currentDepthMapValue = texture(material.depth2D, currentTexCoords).r;
        currentLayerDepth += layerDepth;  
    }

    vec2 prevTexCoords = currentTexCoords + deltaTexCoords;

    float afterDepth  = currentDepthMapValue - currentLayerDepth;
    float beforeDepth = texture(material.depth2D, prevTexCoords).r - currentLayerDepth + layerDepth;
 
    float weight = afterDepth / (afterDepth - beforeDepth);
    vec2 finalTexCoords = prevTexCoords * weight + currentTexCoords * (1.0 - weight);

    return finalTexCoords;
}
