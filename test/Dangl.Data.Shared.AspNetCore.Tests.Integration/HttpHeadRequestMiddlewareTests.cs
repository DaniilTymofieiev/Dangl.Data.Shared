﻿using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Xunit;

namespace Dangl.Data.Shared.AspNetCore.Tests.Integration
{
    public class HttpHeadRequestMiddlewareTests : TestServerBase
    {
        private bool _sendHttpHead = true;

        [Fact]
        public void ArgumentNullExceptionForNullRequestDelegate()
        {
            Assert.Throws<ArgumentNullException>("next", () => new HttpHeadRequestMiddleware(null));
        }

        [Fact]
        public async Task CanMakeHttpHeadRequest()
        {
            await MakeRequest();
            Assert.True(_response.IsSuccessStatusCode);
        }

        [Fact]
        public async Task HttpHeadRequestReturnsEmptyBody()
        {
            await MakeRequest();
            Assert.Equal(0, (await _response.Content.ReadAsStreamAsync()).Length);
        }

        [Fact]
        public async Task HttpGetRequestHasBodyData()
        {
            _sendHttpHead = false;
            await MakeRequest();
            Assert.True(_response.IsSuccessStatusCode);
            Assert.NotEqual(0, (await _response.Content.ReadAsStreamAsync()).Length);
        }

        private async Task MakeRequest()
        {
            var url = GetUrl();
            var client = GetClient();
            var request = new HttpRequestMessage(_sendHttpHead ? HttpMethod.Head : HttpMethod.Get, url);
            _response = await client.SendAsync(request);
        }

        protected override string GetUrl()
        {
            return "/JsonData";
        }
    }
}
