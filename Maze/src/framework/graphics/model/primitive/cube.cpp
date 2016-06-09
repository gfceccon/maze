#include "cube.h"

Cube::Cube(Program* program, const char* tex_fname)
{
	Model::nvertices = 36;
	Model::vertices = new GLfloat[nvertices * 3]{
		0.0f, 0.0f, 0.0f,
		1.0f, 0.0f, 0.0f,
		1.0f, 1.0f, 0.0f,
		1.0f, 1.0f, 0.0f,
		0.0f, 1.0f, 0.0f,
		0.0f, 0.0f, 0.0f,

		0.0f, 0.0f,  1.0f,
		1.0f, 0.0f,  1.0f,
		1.0f, 1.0f,  1.0f,
		1.0f, 1.0f,  1.0f,
		0.0f, 1.0f,  1.0f,
		0.0f, 0.0f,  1.0f,

		0.0f,  1.0f,  1.0f,
		0.0f,  1.0f, 0.0f,
		0.0f,  0.0f, 0.0f,
		0.0f,  0.0f, 0.0f,
		0.0f,  0.0f, 1.0f,
		0.0f,  1.0f, 1.0f,

		1.0f,  1.0f,  1.0f,
		1.0f,  1.0f, 0.0f,
		1.0f,  0.0f, 0.0f,
		1.0f,  0.0f, 0.0f,
		1.0f,  0.0f, 1.0f,
		1.0f,  1.0f, 1.0f,

		0.0f, 0.0f, 0.0f,
		1.0f, 0.0f, 0.0f,
		1.0f, 0.0f, 1.0f,
		1.0f, 0.0f, 1.0f,
		0.0f, 0.0f, 1.0f,
		0.0f, 0.0f, 0.0f,

		0.0f,  1.0f, 0.0f,
		1.0f,  1.0f, 0.0f,
		1.0f,  1.0f,  1.0f,
		1.0f,  1.0f,  1.0f,
		0.0f,  1.0f,  1.0f,
		0.0f,  1.0f, 0.0f
	};
	Model::uvs = new GLfloat[nvertices * 2]{
		0.0f, 0.0f,
		1.0f, 0.0f,
		1.0f, 1.0f,
		1.0f, 1.0f,
		0.0f, 1.0f,
		0.0f, 0.0f,

		0.0f, 0.0f,
		1.0f, 0.0f,
		1.0f, 1.0f,
		1.0f, 1.0f,
		0.0f, 1.0f,
		0.0f, 0.0f,

		0.0f, 1.0f,
		1.0f, 1.0f,
		1.0f, 0.0f,
		1.0f, 0.0f,
		0.0f, 0.0f,
		0.0f, 1.0f,

		0.0f, 1.0f,
		1.0f, 1.0f,
		1.0f, 0.0f,
		1.0f, 0.0f,
		0.0f, 0.0f,
		0.0f, 1.0f,

		0.0f, 1.0f,
		1.0f, 1.0f,
		1.0f, 0.0f,
		1.0f, 0.0f,
		0.0f, 0.0f,
		0.0f, 1.0f,

		0.0f, 1.0f,
		1.0f, 1.0f,
		1.0f, 0.0f,
		1.0f, 0.0f,
		0.0f, 0.0f,
		0.0f, 1.0f
	};
	Model::indices = nullptr;
	Model::normals = nullptr;
	Model::colors = nullptr;
	Model::materials = nullptr;
	Model::init(program, GL_STATIC_DRAW);
	if(tex_fname)
		Model::initTexture(program, tex_fname);
}


Cube::~Cube()
{
}

void Cube::draw()
{
	Model::draw(GL_TRIANGLES);
}
