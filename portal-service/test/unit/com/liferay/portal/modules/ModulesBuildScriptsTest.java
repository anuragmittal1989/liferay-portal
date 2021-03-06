/**
 * Copyright (c) 2000-present Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */

package com.liferay.portal.modules;

import java.io.IOException;

import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;

import org.junit.Assert;
import org.junit.Test;

/**
 * @author Shuyang Zhou
 */
public class ModulesBuildScriptsTest {

	@Test
	public void testScanBuildScripts() throws IOException {
		Files.walkFileTree(
			Paths.get("modules"),
			new SimpleFileVisitor<Path>() {

				@Override
				public FileVisitResult preVisitDirectory(
					Path dirPath, BasicFileAttributes basicFileAttributes) {

					Path buildXmlPath = dirPath.resolve("build.xml");

					if (Files.notExists(buildXmlPath)) {
						Assert.fail("Missing " + buildXmlPath);
					}

					Path ivyXmlPath = dirPath.resolve("ivy.xml");

					if (Files.exists(ivyXmlPath)) {
						Assert.fail("Forbidden " + ivyXmlPath);
					}

					if (Files.exists(dirPath.resolve("bnd.bnd"))) {
						Path buildGradlePath = dirPath.resolve("build.gradle");

						if (Files.notExists(buildGradlePath)) {
							Assert.fail("Missing " + buildGradlePath);
						}

						return FileVisitResult.SKIP_SUBTREE;
					}

					return FileVisitResult.CONTINUE;
				}

			});
	}

}