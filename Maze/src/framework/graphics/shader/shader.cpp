#include "shader.h"

#include <string>
#include <algorithm>
#include <fstream>
#include <sstream>
#include "../../../util/log.h"

Shader::Shader(const char* fname, GLenum type, GLuint program)
{
	std::string str(path);
	str += fname;
	std::ifstream file(str.c_str(), std::ios::in | std::ios::binary);
	if (!file) {
		throw std::runtime_error("File " + str + " does not exist.");
	}

	std::stringstream buffer;
	buffer << file.rdbuf();
	std::string src = buffer.str();
	std::replace(src.begin(), src.end(), '\r', '\n');

	const char* source = src.c_str();

	GLuint shader = glCreateShader(type);
	glShaderSource(shader, 1, &source, nullptr);
	glCompileShader(shader);
	GLint status;
	glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
	if (!status) {
		GLchar info[512];
		glGetShaderInfoLog(shader, 512, nullptr, info);
		Log::error(info);
	} else {
		glAttachShader(program, shader);
	}

	this->shader = shader;
}

Shader::~Shader() {
	glDeleteShader(shader);
}
