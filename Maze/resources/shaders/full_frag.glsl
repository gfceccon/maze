#version 330 core
struct Material {
    sampler2D diffuse2D;
    sampler2D specular2D;
    sampler2D normal2D;
    sampler2D depth2D;
	
	vec3 diffuse;
	vec3 specular;

	bool hasDiffuseTexture;
	bool hasSpecularTexture;
	bool hasNormalTexture;
	bool hasDepthTexture;
	
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

#define NR_POINT_LIGHTS 4

in vec3 FragPosition;
in vec2 TexCoord;
in vec3 Normal;
in mat3 TBN;

out vec4 color;

uniform vec3 ViewPosition;
uniform DirLight directional;
uniform PointLight lights[NR_POINT_LIGHTS];
uniform Material material;

vec3 CalcDirLight(DirLight light, vec3 normal, vec3 viewDir);
vec3 CalcPointLight(PointLight light, vec3 normal, vec3 fragPos, vec3 viewDir);

void main()
{
    vec3 normal = normalize(Normal);
    vec3 viewDirection = normalize(ViewPosition - FragPosition);
    
    vec3 result = CalcDirLight(directional, normal, viewDirection);

    for(int i = 0; i < NR_POINT_LIGHTS; i++)
        result += CalcPointLight(lights[i], normal, FragPosition, viewDirection);
    
    color = vec4(result, 1.0);
}

vec3 CalcDirLight(DirLight light, vec3 normal, vec3 viewDir)
{
    vec3 lightDir = normalize(-light.direction);
    
    float diff = max(dot(normal, lightDir), 0.0);
    
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), objectMaterial.shininess);
    
    //vec3 ambient = light.ambient * vec3(texture(material.diffuse, TexCoord));
    //vec3 diffuse = light.diffuse * diff * vec3(texture(material.diffuse, TexCoord));
    //vec3 specular = light.specular * spec * vec3(texture(material.specular, TexCoord));
	
	vec3 ambient = light.ambient * vec3(texture(material.diffuse2D, TexCoord));
    vec3 diffuse = light.diffuse * diff * vec3(texture(material.diffuse2D, TexCoord));
    vec3 specular = material.specular * light.specular * spec;
    
	return (ambient + diffuse + specular);
}

vec3 CalcPointLight(PointLight light, vec3 normal, vec3 fragPos, vec3 viewDir)
{
    vec3 lightDir = normalize(light.position - fragPos);
    
    float diff = max(dot(normal, lightDir), 0.0);
    
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), objectMaterial.shininess);
	
    float distance = length(light.position - fragPos);
    float attenuation = 1.0f / (light.constant + light.linear * distance + light.quadratic * (distance * distance));    
    
    //vec3 ambient = light.ambient * vec3(texture(material.diffuse, TexCoord));
    //vec3 diffuse = light.diffuse * diff * vec3(texture(material.diffuse, TexCoord));
    //vec3 specular = light.specular * spec * vec3(texture(material.specular, TexCoord));
	
	vec3 ambient = light.ambient * vec3(texture(material.diffuse2D, TexCoord));
    vec3 diffuse = light.diffuse * diff * vec3(texture(material.diffuse2D, TexCoord));
    vec3 specular = material.specular * light.specular * spec;
    
	ambient *= attenuation;
    diffuse *= attenuation;
    specular *= attenuation;
    
	return (ambient + diffuse + specular);
}
